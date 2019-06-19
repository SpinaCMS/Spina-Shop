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

    end
  end
end