class Document < ApplicationRecord
  has_many :share_links, dependent: :destroy
  
  validates :filename, presence: true
  validates :content_type, presence: true
  validates :file_size, presence: true, numericality: { less_than_or_equal_to: 10.megabytes }
  validates :storage_key, presence: true, uniqueness: true
  validates :owner_token, presence: true
  
  before_validation :generate_owner_token, on: :create
  before_validation :generate_storage_key, on: :create
  
  # File type helpers
  def pdf?
    content_type == "application/pdf"
  end
  
  def image?
    content_type.start_with?("image/")
  end
  
  def text?
    content_type.start_with?("text/") || 
    content_type.in?(%w[application/json application/xml application/javascript])
  end
  
  def document?
    content_type.in?(%w[
      application/pdf
      application/msword
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
      application/vnd.ms-excel
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      application/vnd.ms-powerpoint
      application/vnd.openxmlformats-officedocument.presentationml.presentation
    ])
  end
  
  def analyzable?
    pdf? || text?
  end
  
  def human_file_size
    if file_size < 1.kilobyte
      "#{file_size} B"
    elsif file_size < 1.megabyte
      "#{(file_size / 1.kilobyte.to_f).round(1)} KB"
    else
      "#{(file_size / 1.megabyte.to_f).round(2)} MB"
    end
  end
  
  def file_extension
    File.extname(filename).delete_prefix(".")
  end
  
  private
  
  def generate_owner_token
    self.owner_token ||= SecureRandom.urlsafe_base64(32)
  end
  
  def generate_storage_key
    self.storage_key ||= "#{SecureRandom.uuid}/#{filename}"
  end
end

