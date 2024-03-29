require 'spina/shop/view_helpers'
require 'spina/shop/admin_helpers'
require 'spina/shop/simple_linear_regression'
require 'spina/shop/errors/empty_order'
require 'spina/shop/errors/order_already_received'

module Spina
  module Shop
    class Railtie < Rails::Railtie

      initializer "spina_shop.view_helpers" do
        ActiveSupport.on_load(:action_view) do 
          include Spina::Shop::ViewHelpers
          include Spina::Shop::AdminHelpers
        end
      end

      initializer "spina_shop.assets.precompile" do |app|
        app.config.assets.precompile += [
          "spina/shop/admin/shop.js",
          "spina/shop/admin/shop.css",
          "spina/shop/delete-big.png",
          "spina/shop/delete-big-confirm.png",
          "spina.css",
          "spina/admin/application.js"
        ]
      end

    end
  end
end