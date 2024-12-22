# syntax=docker/dockerfile:1
FROM ruby:3.3-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    libyaml-dev \
    nodejs \
    git \
    curl \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /rails

# Set production environment
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p tmp/pids tmp/cache tmp/sockets log storage

# Precompile assets (with dummy secret key, no DB needed)
RUN SECRET_KEY_BASE=dummy_key_for_assets bundle exec rails assets:precompile

# Create inline startup script
RUN echo '#!/bin/bash\nset -e\necho "=== STARTING OPENSEND ==="\necho "Running database migrations..."\nbundle exec rails db:prepare\necho "Database ready!"\nexec bundle exec puma -C config/puma.rb' > /start.sh && chmod +x /start.sh

EXPOSE 3000

ENTRYPOINT ["/bin/bash", "/start.sh"]
