require 'spina'
require 'pg'
require 'refile'
require 'ransack'
require 'statesman'
require "email_validator"
require "delocalize"
require "bourbon"

module Spina
  module Shop
    class Engine < ::Rails::Engine
      isolate_namespace Spina

      # Load decorators
      config.to_prepare do
        Dir.glob(Engine.root + "app/decorators/**/*_decorator*.rb").each do |decorator|
          require_dependency(decorator)
        end
      end
    end
  end
end