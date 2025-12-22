source "https://rubygems.org"

ruby ">= 3.2.0"

gem "rails", "~> 7.1.0"
gem "pg", "~> 1.5"
gem "puma", "~> 6.4"
gem "sprockets-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "bcrypt", "~> 3.1"
gem "bootsnap", require: false

# File storage
gem "aws-sdk-s3", "~> 1.143"  # Vercel Blob uses S3-compatible API
gem "activestorage"


# Environment variables
gem "dotenv-rails", groups: [:development, :test]

# JSON Web Tokens for secure links
gem "jwt", "~> 2.7"

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "rspec-rails", "~> 7.1"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "web-console"
end

group :production do
  gem "rack-timeout"
end

