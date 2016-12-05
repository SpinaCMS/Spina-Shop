module Spina
  module Admin
    class OrdersController < AdminController
      load_and_authorize_resource class: "Spina::Order"

      before_action :set_breadcrumbs

      def new
      end

      def index
        @q = Order.ransack(params[:q])
        @orders = @q.result.confirmed.sorted.page(params[:page]).per(25)
      end

      def to_be_shipped
        @q = Order.ransack(params[:q])
        @orders = @q.result.in_state(:paid, :order_picking).sorted.page(params[:page]).per(25)
        render :index
      end

      def failed
        @q = Order.ransack(params[:q])
        @orders = @q.result.in_state(:failed).sorted.page(params[:page]).per(25)
        render :index
      end

      def show
        add_breadcrumb @order.number
      end

      def transition
        @orders = Order.where(id: params[:order_ids])
        if params[:transition_to] == "order_picking_and_shipped"
          @orders.each do |order|
            order.transition_to("order_picking")
            order.transition_to("shipped")
          end
        else
          @orders.each do |order|
            order.transition_to(params[:transition_to])
          end
        end

        if params[:transition_to] == "order_picking"
          flash[:success] = "<strong>Pakbonnen</strong> worden nu geprint"
        elsif params[:transition_to] == "shipping"
          flash[:success] = "<strong>Verzendlabels</strong> worden nu aangemaakt"
        else
          flash[:success] = "<strong>Pakbonnen en verzendlabels</strong> worden nu aangemaakt"
        end
        redirect_to :back
      end

      private

        def set_breadcrumbs
          add_breadcrumb "Bestellingen", admin_orders_path
        end
    end
  end
end