module Spina::Shop
  module Admin
    module Stock
      class StockOrderProductsController < AdminController

        def new
          @stock_orders = StockOrder.concept.order(created_at: :desc)
          @products = Product.where(id: params[:product_ids]).stock_forecast
        end

        def create
          @stock_order = StockOrder.find_by(id: params[:stock_order_id])
          return if @stock_order.ordered?
          
          params[:products].each do |product|
            ordered_stock = @stock_order.ordered_stock.where(product_id: product["id"]).first_or_initialize
            ordered_stock.quantity = product["quantity"]
            ordered_stock.save
          end

          redirect_to spina.shop_admin_stock_order_path(@stock_order)
        end

      end
    end
  end
end