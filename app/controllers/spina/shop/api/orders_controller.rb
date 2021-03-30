module Spina::Shop
  module Api
    class OrdersController < ApiController
      
      def index
        render json: []  
      end
      
      def to_process
        @orders = Order.to_process.order(:order_number)
        render :index
      end
      
      def show
        @order = Order.find(params[:id])
      end
      
    end
  end
end
  