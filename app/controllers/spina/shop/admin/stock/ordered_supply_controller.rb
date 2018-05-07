module Spina::Shop
  module Admin
    module Stock
      class OrderedSupplyController < AdminController

        def destroy
          @supply_order = SupplyOrder.find(params[:supply_order_id])
          return if @supply_order.ordered?

          @ordered_supply = @supply_order.ordered_supply.find(params[:id])
          @ordered_supply.destroy
          redirect_to spina.shop_admin_supply_order_path(@supply_order)
        end

      end
    end
  end
end