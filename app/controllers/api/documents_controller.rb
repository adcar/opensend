module Api
  class DocumentsController < ApplicationController
    skip_before_action :verify_authenticity_token
    
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
        AnalyzeDocumentJob.perform_later(@document.id) if @document.analyzable?
        
        render json: document_json(@document), status: :created
      else
        render json: { errors: @document.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    def analyze
      @document = current_documents.find(params[:id])
      
      if @document.analyzable?
        AnalyzeDocumentJob.perform_now(@document.id)
        @document.reload
        render json: document_json(@document)
      else
        render json: { error: "This file type cannot be analyzed" }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Document not found" }, status: :not_found
    end
    
    private
    
    def document_json(doc)
      {
        id: doc.id,
        filename: doc.filename,
        file_size: doc.human_file_size,
        content_type: doc.content_type,
        ai_summary: doc.ai_summary,
        ai_title: doc.ai_title,
        ai_metadata: doc.ai_metadata,
        created_at: doc.created_at.iso8601,
        show_url: document_path(doc),
        analyzable: doc.analyzable?
      }
    end
  end
end

