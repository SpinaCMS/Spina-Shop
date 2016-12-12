module Spina
  module Admin
    class OrdersController < ShopController
      load_and_authorize_resource class: "Spina::Order"

      before_action :set_breadcrumbs

      def new
      end

      def index
        @q = Order.ransack(params[:q])
        @orders = @q.result.confirmed.sorted.page(params[:page]).per(25)
      end

      def to_process
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

      def edit
        add_breadcrumb @order.number, admin_order_path(@order)
        add_breadcrumb t('spina.edit')
      end

      def update
        if @order.update_attributes!(order_params)
          redirect_to admin_order_path(@order)
        else
          render :edit
        end
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
          flash[:success] = t('spina.shop.orders.start_order_picking_success')
        elsif params[:transition_to] == "shipping"
          flash[:success] = t('spina.shop.orders.ship_order_success')
        else
          flash[:success] = t('spina.shop.orders.start_picking_and_ship_success')
        end
        redirect_to :back
      end

      private

        def order_params
          params.require(:order).permit!
        end

        def set_breadcrumbs
          add_breadcrumb Spina::Order.model_name.human(count: 2), admin_orders_path
        end
    end
  end
end