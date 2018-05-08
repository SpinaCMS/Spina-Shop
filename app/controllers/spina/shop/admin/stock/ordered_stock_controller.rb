module Spina::Shop
  module Admin
    module Stock
      class OrderedStockController < AdminController

        def destroy
          @stock_order = StockOrder.find(params[:stock_order_id])
          return if @stock_order.ordered?

          @ordered_stock = @stock_order.ordered_stock.find(params[:id])
          @ordered_stock.destroy
          redirect_to spina.shop_admin_stock_order_path(@stock_order)
        end

      end
    end
  end
end