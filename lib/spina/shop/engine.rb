module Spina
  module Shop
    class Engine < ::Rails::Engine
      isolate_namespace Spina
      
      config.autoload_paths += %W( #{config.root}/state_machines)

      initializer "spina_shop.include_view_helpers" do |app|
        ActiveSupport.on_load :action_view do
          include Spina::Admin::ShopHelper
        end
      end
    end
  end
end
