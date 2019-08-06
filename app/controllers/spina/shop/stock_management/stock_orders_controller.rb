module Spina::Shop
  module StockManagement
    class StockOrdersController < StockManagementController

      def index
        @expected_today = StockOrder.open.expected_today
        @expected_later = StockOrder.open.where("expected_delivery IS NULL OR expected_delivery != ?", Date.today)
      end

      def show
        @stock_order = StockOrder.find(params[:id])
      end

      def close_order
        @stock_order = StockOrder.open.find(params[:id])
        @stock_order.update_attributes(closed_at: Time.zone.now)
        redirect_to spina.shop_stock_management_stock_orders_path
      end

      def edit
        @stock_order = StockOrder.find(params[:id])
      end

      def update
        @stock_order = StockOrder.find(params[:id])

        if @stock_order.update_attributes(stock_order_params)
          redirect_to spina.shop_stock_management_stock_order_path(@stock_order)
        else
          render :edit
        end
      end

      private

        def stock_order_params
          params.require(:stock_order).permit(:feedback)
        end

    end
  end
end