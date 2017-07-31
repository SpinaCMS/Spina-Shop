require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require "spina/shop"

module Dummy
  class Application < Rails::Application
    config.load_defaults 5.1
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.i18n.default_locale = :nl
  end
end

