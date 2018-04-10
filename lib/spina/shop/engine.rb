require 'spina'
require 'pg'
require 'ransack'
require 'statesman'
require "email_validator"
require "delocalize"
require "bourbon"
require "prawn"
require "prawn/table"
require "ruby-measurement"
require "valvat"

module Spina
  module Shop
    class Engine < ::Rails::Engine
      isolate_namespace Spina::Shop

      # Load decorators
      config.to_prepare do
        Dir.glob(Engine.root + "app/decorators/**/*_decorator*.rb").each do |decorator|
          require_dependency(decorator)
        end
      end
    end
  end
end