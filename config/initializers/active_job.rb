# Use async adapter for background jobs in development
# In production, this would be configured differently (e.g., Sidekiq, Solid Queue)
Rails.application.config.active_job.queue_adapter = :async

