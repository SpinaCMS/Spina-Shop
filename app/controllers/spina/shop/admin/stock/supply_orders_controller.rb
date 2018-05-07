module Spina::Shop
  module Admin
    module Stock
      class SupplyOrdersController < AdminController
        layout 'spina/shop/admin/stock'

        before_action :set_breadcrumbs

        def index
          @supply_orders = SupplyOrder.order(created_at: :desc)
        end

        def show
          @supply_order = SupplyOrder.find(params[:id])
          add_breadcrumb "##{@supply_order.id}"
        end

        def new
          @supply_order = SupplyOrder.new
          @suppliers = Supplier.order(:name)
        end

        def create
          @supply_order = SupplyOrder.create(supply_order_params)
          redirect_to spina.shop_admin_supply_orders_path
        end

        private

          def set_breadcrumbs
            add_breadcrumb "Voorraad", spina.shop_admin_stock_forecast_path
            add_breadcrumb SupplyOrder.model_name.human(count: 2), spina.shop_admin_supply_orders_path
          end

          def supply_order_params
            params.require(:supply_order).permit(:supplier_id)
          end

      end
    end
  end
end
