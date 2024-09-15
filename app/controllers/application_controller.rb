class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  helper_method :owner_token, :current_documents
  
  private
  
  def owner_token
    session[:owner_token] ||= SecureRandom.urlsafe_base64(32)
  end
  
  def current_documents
    Document.where(owner_token: owner_token).order(created_at: :desc)
  end
end

