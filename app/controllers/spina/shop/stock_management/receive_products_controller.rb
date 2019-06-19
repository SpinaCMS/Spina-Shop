module Spina::Shop
  module StockManagement
    class ReceiveProductsController < StockManagementController

      def new
        @stock_order = StockOrder.find(params[:stock_order_id])
        @ordered_stock = @stock_order.ordered_stock.find(params[:ordered_stock_id])
      end

      def create
        @stock_order = StockOrder.find(params[:stock_order_id])
        @ordered_stock = @stock_order.ordered_stock.find(params[:ordered_stock_id])
        @ordered_stock.update(received: params[:received])
        redirect_to [spina, :shop, :stock_management, @stock_order]
      end

    end
  end
end