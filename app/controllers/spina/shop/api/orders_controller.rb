module Spina::Shop
  module Api
    class OrdersController < ApiController
      rescue_from ActiveRecord::RecordNotFound, with: :return_404
      
      def index
        render json: []  
      end
      
      def to_process
        @orders = Order.to_process.order(:order_number)
        render :index
      end
      
      def ready_for_pickup
        @orders = Order.in_state(:ready_for_pickup).order(:order_number)
        render :index
      end
      
      def start_preparing
        @order = Order.find(params[:id])
        @order.transition_to(:preparing, user: params[:user])
        head :ok
      end
      
      def show
        @order = Order.find(params[:id])
      end
      
      private
      
        def return_404
          head :not_found and return
        end
      
    end
  end
end
  