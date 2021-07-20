module Spina::Shop
  module Admin
    class OrderPickListsController < AdminController
      
      def show
        @order = Order.find(params[:order_id])
        @order_pick_list = @order.order_pick_list
      end
      
    end
  end
end