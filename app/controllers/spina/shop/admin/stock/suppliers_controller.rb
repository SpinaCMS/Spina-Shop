module Spina::Shop
  module Admin
    module Stock
      class SuppliersController < AdminController
        layout 'spina/shop/admin/stock'

        before_action :set_breadcrumbs

        def new
          @supplier = Supplier.new
        end

        def create
        end

        def edit
        end

        def index
          add_breadcrumb Supplier.model_name.human(count: 2)
          @suppliers = Supplier.order(:name)
        end

        def update
        end

        def destroy
        end

        private

          def set_breadcrumbs
            add_breadcrumb "Voorraad", spina.shop_admin_stock_forecast_path
          end

      end
    end
  end
end
