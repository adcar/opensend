class SharesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:verify, :request_access]
  before_action :set_share_link
  before_action :check_expiration
  before_action :check_country
  before_action :check_passcode, only: [:show, :download, :preview]
  before_action :check_email_access, only: [:show, :download, :preview]
  
  def show
    @share_link.record_view!(
      email: session[:share_email],
      ip_address: request.remote_ip
    )
    
    @document = @share_link.document
    @preview_service = FilePreviewService.new(@document)
  end
  
  def verify
    if @share_link.passcode_protected?
      if @share_link.authenticate_passcode(params[:passcode])
        session["passcode_verified_#{@share_link.id}"] = true
        redirect_to share_path(token: @share_link.token)
      else
        redirect_to share_path(token: @share_link.token), alert: "Invalid passcode"
      end
    else
      redirect_to share_path(token: @share_link.token)
    end
  end
  
  def request_access
    email = params[:email]&.strip&.downcase
    
    unless email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)
      return redirect_to share_path(token: @share_link.token), alert: "Valid email required"
    end
    
    access_request = @share_link.access_requests.find_or_create_by(email: email) do |ar|
      ar.ip_address = request.remote_ip
      ar.user_agent = request.user_agent
    end
    
    access_request.verify! unless access_request.verified?
    session[:share_email] = email
    
    redirect_to share_path(token: @share_link.token)
  end
  
  def preview
    document = @share_link.document
    file_data = StorageService.retrieve(document.storage_key)
    
    if file_data
      # Set appropriate headers for inline display
      response.headers['Content-Security-Policy'] = "frame-ancestors 'self'"
      
      send_data file_data,
                filename: document.filename,
                type: document.content_type,
                disposition: "inline"
    else
      render plain: "File not found", status: :not_found
    end
  end
  
  def download
    unless @share_link.allow_download
      return render plain: "Downloads not allowed", status: :forbidden
    end
    
    @share_link.record_download!(
      email: session[:share_email],
      ip_address: request.remote_ip
    )
    
    document = @share_link.document
    file_data = StorageService.retrieve(document.storage_key)
    
    if file_data
      send_data file_data,
                filename: document.filename,
                type: document.content_type,
                disposition: "attachment"
    else
      render plain: "File not found", status: :not_found
    end
  end
  
  private
  
  def set_share_link
    @share_link = ShareLink.includes(:document).find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    render "errors/not_found", status: :not_found
  end
  
  def check_expiration
    if @share_link.expired?
      render "shares/expired", status: :gone
    end
  end
  
  def check_country
    return unless @share_link.country_restricted?
    
    country_code = detect_country(request.remote_ip)
    
    unless @share_link.allows_country?(country_code)
      render "shares/country_blocked", status: :forbidden
    end
  end
  
  def check_passcode
    if @share_link.passcode_protected? && !session["passcode_verified_#{@share_link.id}"]
      render "shares/passcode_required"
    end
  end
  
  def check_email_access
    if @share_link.require_email && session[:share_email].blank?
      render "shares/email_required"
    end
  end
  
  def detect_country(ip)
    return "US" if ip == "127.0.0.1" || ip == "::1"
    
    begin
      response = Net::HTTP.get(URI("http://ip-api.com/json/#{ip}?fields=countryCode"))
      data = JSON.parse(response)
      data["countryCode"] || "US"
    rescue
      "US"
    end
  end
end
