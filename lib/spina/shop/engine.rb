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
require "view_component"

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
      
      initializer "spina.shop.assets" do |app|
        # Add views to purge for Tailwind
        Spina.config.tailwind_content.concat [
          "#{Spina::Shop::Engine.root}/app/views/**/*.*",
          "#{Spina::Shop::Engine.root}/app/helpers/**/*.*",
          "#{Spina::Shop::Engine.root}/app/components/**/*.*",
          "#{Spina::Shop::Engine.root}/app/**/application.tailwind.css"
        ]
      end
    end
  end
end