class SharesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:verify]
  before_action :set_share_link
  before_action :check_expiration
  before_action :check_view_limit, only: [:show, :preview]
  before_action :check_country
  before_action :check_passcode, only: [:show, :download, :preview]
  
  def show
    @share_link.record_view!(ip_address: request.remote_ip) unless @share_link.view_limit_reached?
    
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
    
    if @share_link.download_limit_reached?
      return render "shares/limit_reached", status: :forbidden
    end
    
    @share_link.record_download!(ip_address: request.remote_ip)
    
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
  
  def check_view_limit
    if @share_link.view_limit_reached?
      render "shares/limit_reached", status: :forbidden
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
