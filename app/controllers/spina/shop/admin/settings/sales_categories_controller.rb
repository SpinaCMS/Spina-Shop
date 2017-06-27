module Spina::Shop
  module Admin
    module Settings
      class SalesCategoriesController < ShopController
        layout 'spina/admin/admin', except: [:index]

        def index

        end

      end
    end
  end
end
