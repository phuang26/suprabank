require File.expand_path('../boot', __FILE__)
require 'dotenv'
require 'rails/all'; Dotenv.load ".env.local", ".env.#{Rails.env}"


ActiveSupport::Deprecation.silenced = true
ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:silence] = Proc.new { |message, callstack| }
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
ActiveSupport::Deprecation.behavior = :silence
Bundler.require(*Rails.groups)

Serrano.configuration do |config|
  config.base_url = "https://api.crossref.org"
  config.mailto = "stephan.sinn@kit.edu"
end


module Suprabank
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib)

    ActsAsTaggableOn.force_lowercase = true
    ActsAsTaggableOn.remove_unused_tags = true

    config.assets.paths << "#{Rails}/vendor/assets/fonts"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    # config.action_dispatch.default_headers = {
    #    'Access-Control-Allow-Origin' => 'http://datascore-jupyterhub.int.kit.edu:8000',
    #    'Access-Control-Request-Method' => %w{GET POST OPTIONS}.join(",")
    # }
  end
end
