class ShareLink < ApplicationRecord
  belongs_to :document
  has_many :access_requests, dependent: :destroy
  
  has_secure_password :passcode, validations: false
  
  validates :token, presence: true, uniqueness: true
  validates :document, presence: true
  validate :expires_at_must_be_future, if: :expires_at_changed?
  
  before_validation :generate_token, on: :create
  
  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at IS NOT NULL AND expires_at <= ?", Time.current) }
  
  # Country list for restrictions
  COUNTRIES = {
    "US" => "United States",
    "GB" => "United Kingdom", 
    "CA" => "Canada",
    "AU" => "Australia",
    "DE" => "Germany",
    "FR" => "France",
    "JP" => "Japan",
    "CN" => "China",
    "IN" => "India",
    "BR" => "Brazil",
    "MX" => "Mexico",
    "ES" => "Spain",
    "IT" => "Italy",
    "NL" => "Netherlands",
    "SE" => "Sweden",
    "NO" => "Norway",
    "DK" => "Denmark",
    "FI" => "Finland",
    "PL" => "Poland",
    "RU" => "Russia",
    "KR" => "South Korea",
    "SG" => "Singapore",
    "NZ" => "New Zealand",
    "IE" => "Ireland",
    "CH" => "Switzerland",
    "AT" => "Austria",
    "BE" => "Belgium",
    "PT" => "Portugal"
  }.freeze
  
  def expired?
    expires_at.present? && expires_at <= Time.current
  end
  
  def active?
    !expired?
  end
  
  def passcode_protected?
    passcode_digest.present?
  end
  
  def country_restricted?
    allowed_countries.present? || blocked_countries.present?
  end
  
  def allows_country?(country_code)
    return true unless country_restricted?
    
    if allowed_countries.present?
      allowed_countries.include?(country_code)
    elsif blocked_countries.present?
      !blocked_countries.include?(country_code)
    else
      true
    end
  end
  
  def record_view!(email: nil, ip_address: nil)
    increment!(:view_count)
    update!(last_viewed_at: Time.current)
    
    if email.present?
      log_entry = {
        email: email,
        ip_address: ip_address,
        action: "view",
        timestamp: Time.current.iso8601
      }
      update!(access_log: access_log + [log_entry])
    end
  end
  
  def record_download!(email: nil, ip_address: nil)
    increment!(:download_count)
    
    if email.present?
      log_entry = {
        email: email,
        ip_address: ip_address,
        action: "download",
        timestamp: Time.current.iso8601
      }
      update!(access_log: access_log + [log_entry])
    end
  end
  
  def share_url
    Rails.application.routes.url_helpers.share_url(token: token, host: ENV.fetch("APP_HOST", "localhost:5000"))
  end
  
  private
  
  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(16)
  end
  
  def expires_at_must_be_future
    if expires_at.present? && expires_at <= Time.current
      errors.add(:expires_at, "must be in the future")
    end
  end
end
