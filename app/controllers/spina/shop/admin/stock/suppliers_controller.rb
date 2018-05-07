module Spina::Shop
  module Admin
    module Stock
      class SuppliersController < AdminController
        layout 'spina/shop/admin/stock'

        before_action :set_breadcrumbs

        def index
          @suppliers = Supplier.order(:name)
        end

        private

          def set_breadcrumbs
            add_breadcrumb "Voorraad"
          end

      end
    end
  end
end
