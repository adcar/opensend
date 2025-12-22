require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Opensend
  class Application < Rails::Application
    config.load_defaults 7.1
    config.autoload_lib(ignore: %w(assets tasks))
    
    # Time zone
    config.time_zone = "UTC"
    
    # Generators configuration
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.stylesheets false
      g.javascripts false
      g.helper false
    end
  end
end

