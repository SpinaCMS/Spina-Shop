require 'spina'
require 'pg'
require 'ransack'
require 'statesman'
require "email_validator"
require "delocalize"
require "prawn-svg"
require "prawn"
require "prawn/table"
require "ruby-measurement"
require "valvat"
require "pg_search"
require "jbuilder"

# Let's get rid of these asap!
require "jquery-rails"
require "haml-rails"

module Spina
  module Shop
    class Engine < ::Rails::Engine
      isolate_namespace Spina::Shop

      # Load decorators
      config.to_prepare do
        Dir.glob(Engine.root + "app/decorators/**/*_decorator*.rb").each do |decorator|
          require_dependency(decorator)
        end

        # Mimetype Excel
        Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx
      end
      
      config.before_initialize do
        # Register the pro plugin
        ::Spina::Plugin.register do |plugin|
          plugin.name = 'shop'
          plugin.namespace = 'shop'
        end
        
        Spina::Part.register(Spina::Parts::Product, Spina::Parts::ProductBundle, Spina::Parts::ProductCategory)
      end
      
    end
  end
end