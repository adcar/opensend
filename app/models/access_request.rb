class AccessRequest < ApplicationRecord
  belongs_to :share_link
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :share_link, presence: true
  
  scope :verified, -> { where.not(verified_at: nil) }
  scope :pending, -> { where(verified_at: nil) }
  
  def verified?
    verified_at.present?
  end
  
  def verify!
    update!(verified_at: Time.current)
  end
end

