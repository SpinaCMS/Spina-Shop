module Spina::Shop
  module Admin
    module Settings
      class SalesCategoriesController < ShopController
        layout 'spina/admin/admin', except: [:index]

        def index
          @sales_categories = SalesCategory.all
        end

      end
    end
  end
end
