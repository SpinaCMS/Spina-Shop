module Spina::Shop
  module StockManagement
    class OrderPickingController < StockManagementController
      
      def show
        @orders = Spina::Shop::Order.in_state(:preparing).where(id: params[:order_id])
      end
      
    end
  end
end