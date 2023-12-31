require_relative "boot"

require "rails/all"
require_relative '../lib/util'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Dotenv::Railtie.load

module Audit
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.ficture_replacement :factory_bot
      g.view_specs false
      g.helper_specs false
    end

    config.eager_load_paths += %W{
    #{config.root}/lib
    }

    config.eager_load_paths += %W{
    #{config.root}/app/channels/account_channel.rb
    }

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
