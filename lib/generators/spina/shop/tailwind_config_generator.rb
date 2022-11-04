module Spina
  module Shop
    class TailwindConfigGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      
      def create_tailwind_config_file
        template 'app/assets/config/spina/shop/tailwind.config.js'
      end
      
    end
  end
end