class ShareLinksController < ApplicationController
  before_action :set_document
  before_action :set_share_link, only: [:destroy]
  
  def index
    @share_links = @document.share_links.order(created_at: :desc)
    
    respond_to do |format|
      format.html
      format.json { render json: @share_links }
    end
  end
  
  def create
    @share_link = @document.share_links.build(share_link_params)
    
    if @share_link.save
      respond_to do |format|
        format.html { redirect_to document_path(@document), notice: "Share link created successfully" }
        format.json do
          render json: {
            id: @share_link.id,
            token: @share_link.token,
            url: share_url(token: @share_link.token),
            name: @share_link.name,
            allow_download: @share_link.allow_download,
            expires_at: @share_link.expires_at&.iso8601,
            passcode_protected: @share_link.passcode_protected?,
            created_at: @share_link.created_at.iso8601
          }, status: :created
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to document_path(@document), alert: @share_link.errors.full_messages.join(", ") }
        format.json { render json: { errors: @share_link.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @share_link.destroy
    
    respond_to do |format|
      format.html { redirect_to document_path(@document), notice: "Share link deleted" }
      format.json { head :no_content }
    end
  end
  
  private
  
  def set_document
    @document = current_documents.find(params[:document_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Document not found" }
      format.json { render json: { error: "Document not found" }, status: :not_found }
    end
  end
  
  def set_share_link
    @share_link = @document.share_links.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to document_path(@document), alert: "Share link not found" }
      format.json { render json: { error: "Share link not found" }, status: :not_found }
    end
  end
  
  def share_link_params
    params.require(:share_link).permit(:name, :allow_download, :expires_at, :passcode)
  end
end

