class ShareLink < ApplicationRecord
  belongs_to :document
  has_many :access_requests, dependent: :destroy
  
  has_secure_password :passcode, validations: false
  
  MAX_EXPIRATION_DAYS = 30
  
  validates :token, presence: true, uniqueness: true
  validates :document, presence: true
  validates :expires_at, presence: true
  validate :expires_at_must_be_future, if: :expires_at_changed?
  validate :expires_at_within_max_duration, if: :expires_at_changed?
  
  before_validation :generate_token, on: :create
  before_validation :set_default_expiration, on: :create
  
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
    !expired? && !view_limit_reached? && !download_limit_reached?
  end
  
  def view_limit_reached?
    max_views.present? && view_count >= max_views
  end
  
  def download_limit_reached?
    max_downloads.present? && download_count >= max_downloads
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
  
  def record_view!(ip_address: nil)
    increment!(:view_count)
    update!(last_viewed_at: Time.current)
  end
  
  def record_download!(ip_address: nil)
    increment!(:download_count)
  end
  
  def share_url
    Rails.application.routes.url_helpers.share_url(token: token, host: ENV.fetch("APP_HOST", "localhost:5000"))
  end
  
  private
  
  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(16)
  end
  
  def set_default_expiration
    self.expires_at ||= MAX_EXPIRATION_DAYS.days.from_now.end_of_day
  end
  
  def expires_at_must_be_future
    if expires_at.present? && expires_at <= Time.current
      errors.add(:expires_at, "must be in the future")
    end
  end
  
  def expires_at_within_max_duration
    if expires_at.present? && expires_at > MAX_EXPIRATION_DAYS.days.from_now.end_of_day
      errors.add(:expires_at, "cannot be more than #{MAX_EXPIRATION_DAYS} days from now")
    end
  end
end
