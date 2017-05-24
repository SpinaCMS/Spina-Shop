module Spina
  module Admin
    module Settings
      class ShopController < AdminController
        before_action -> { add_breadcrumb t('spina.shop.settings') }, only: [:index]
      end
    end
  end
end