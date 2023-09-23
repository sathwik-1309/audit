# config/initializers/sidekiq.rb

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") || "redis://localhost:6379/1" } # Adjust the Redis URL as needed
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") || "redis://localhost:6379/1" }# Same Redis URL as in the server configuration
end
  