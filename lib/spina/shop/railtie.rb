require 'spina/shop/view_helpers'

module Spina
  module Shop
    class Railtie < Rails::Railtie
      initializer "spina.shop.view_helpers" do
        ActiveSupport.on_load( :action_view ){ include Spina::Shop::ViewHelpers } 
      end
    end
  end
end
