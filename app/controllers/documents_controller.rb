class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :destroy, :download, :update]
  
  def index
    @documents = current_documents
  end
  
  def show
    @share_link = @document.share_links.first || @document.share_links.create!
  end
  
  def create
    file = params[:file]
    
    unless file
      return render json: { error: "No file provided" }, status: :unprocessable_entity
    end
    
    if file.size > 10.megabytes
      return render json: { error: "File size exceeds 10MB limit" }, status: :unprocessable_entity
    end
    
    @document = Document.new(
      filename: file.original_filename,
      content_type: file.content_type,
      file_size: file.size,
      owner_token: owner_token
    )
    
    if @document.save
      StorageService.store(file, @document.storage_key)
      @document.share_links.create!
      
      render json: {
        id: @document.id,
        filename: @document.filename,
        redirect_url: document_path(@document)
      }, status: :created
    else
      render json: { errors: @document.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    @share_link = @document.share_links.first
    
    if @share_link.update(share_link_params)
      redirect_to document_path(@document), notice: "Settings saved"
    else
      redirect_to document_path(@document), alert: @share_link.errors.full_messages.join(", ")
    end
  end
  
  def destroy
    StorageService.delete(@document.storage_key)
    @document.destroy
    redirect_to root_path, notice: "File deleted"
  end
  
  def download
    file_data = StorageService.retrieve(@document.storage_key)
    
    if file_data
      send_data file_data,
                filename: @document.filename,
                type: @document.content_type,
                disposition: "attachment"
    else
      render plain: "File not found", status: :not_found
    end
  end
  
  private
  
  def set_document
    @document = current_documents.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "File not found"
  end
  
  def share_link_params
    permitted = params.require(:share_link).permit(
      :require_email, 
      :allow_download, 
      :expires_at, 
      :passcode,
      allowed_countries: [],
      blocked_countries: []
    )
    
    # Set expiration to end of day if date provided
    if permitted[:expires_at].present?
      date = Date.parse(permitted[:expires_at]) rescue nil
      permitted[:expires_at] = date.end_of_day if date
    end
    
    permitted
  end
end
