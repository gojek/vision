require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Vision
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

     # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Jakarta'
    config.generators do |g|
        g.test_framework :rspec,
            fixtures: true,
            view_specs: false,
            helper_specs: false,
            routing_specs:false,
            controller_specs: true,
            request_spec: false
        g.fixture_replacement :factory_girl, dir: "spec/factories"
    end



    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.assets.precompile += %w(.svg .eot .woff .ttf .png .jpg .jpeg .gif)
    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.active_record.belongs_to_required_by_default = true

    config.autoload_paths << "#{Rails.root}/lib"
    config.autoload_paths << "#{Rails.root}/app/modules"
    # add bower components to it
    config.assets.paths << Rails.root.join("vendor", "assets", "bower_components")

    # add fonts
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    config.load_defaults 5.2

    # For queing process backend
    config.active_job.queue_adapter = :sucker_punch
  end
end

SuckerPunch.logger = Rails.logger
