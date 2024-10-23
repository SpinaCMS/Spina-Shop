module Spina::Shop
  module Api
    class OrdersController < ApiController
      rescue_from ActiveRecord::RecordNotFound, with: :return_404
      
      skip_before_action :verify_authenticity_token, only: [:transition, :ship]
      
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
      
      def transition
        @order = Order.find(params[:id])
        @order.transition_to(params[:transition_to], user: params[:user])
        head :ok
      end
      
      def ship
        @order = Order.find(params[:id])
        # Number of labels to print between 1 and 10 (1 = default)
        @order.number_of_labels_to_print = [1, [params[:quantity].to_i, 10].min].max
        @order.transition_to!("shipped", user: params[:user])
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
  