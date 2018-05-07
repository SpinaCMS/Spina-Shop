module Spina::Shop
  module Admin
    module Stock
      class SupplyOrderProductsController < AdminController

        def new
          @supply_orders = SupplyOrder.concept.order(created_at: :desc)
          @products = Product.where(id: params[:product_ids]).stock_forecast
        end

        def create
          @supply_order = SupplyOrder.find_by(id: params[:supply_order_id])
          return if @supply_order.ordered?
          
          params[:products].each do |product|
            ordered_supply = @supply_order.ordered_supply.where(product_id: product["id"]).first_or_initialize
            ordered_supply.quantity = product["quantity"]
            ordered_supply.save
          end

          redirect_to spina.shop_admin_supply_order_path(@supply_order)
        end

      end
    end
  end
end