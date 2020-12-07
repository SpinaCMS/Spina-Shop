module Spina::Shop
  module StockManagement
    class OrdersController < StockManagementController
      
      def index
        @orders = Spina::Shop::Order.in_state(:preparing).order(:order_prepared_at)
      end
      
    end
  end
end