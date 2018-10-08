module Spina::Shop
  module Admin
    class OrdersController < AdminController
      before_action :set_breadcrumbs

      def new
        @order = Order.new
        add_breadcrumb t('spina.shop.orders.new')
      end

      def create
        @order = Order.new(order_params)
        @order.validate_details = true
        if @order.save
          redirect_to spina.shop_admin_order_path(@order)
        else
          add_breadcrumb t('spina.shop.orders.new')
          render :new
        end
      end

      def cancel
        @order = Order.find(params[:id])
        @order.transition_to!(:cancelled, user: current_spina_user.name, ip_address: request.remote_ip)
        redirect_to spina.shop_admin_order_path(@order)
      end

      def receive
        @order = Order.find(params[:id])
        @order.transition_to!(:received, user: current_spina_user.name, ip_address: request.remote_ip)
        redirect_to spina.shop_admin_order_path(@order)
      end

      def pay
        @order = Order.find(params[:id])
        @order.transition_to!(:paid, user: current_spina_user.name, ip_address: request.remote_ip)
        redirect_to spina.shop_admin_order_path(@order)
      end

      def order_picked_up
        @order = Order.find(params[:id])
        @order.transition_to!(:picked_up, user: current_spina_user.name, ip_address: request.remote_ip)
        redirect_to spina.shop_admin_order_path(@order)
      end

      def delivered
        @order = Order.find(params[:id])
        @order.transition_to!(:delivered, user: current_spina_user.name, ip_address: request.remote_ip)
        redirect_to spina.shop_admin_order_path(@order)
      end

      def index
        @q = Order.ransack(params[:q])
        @orders = @q.result.confirmed.sorted.includes(:order_items, :order_transitions).page(params[:page]).per(15)
      end

      def to_process
        @q = Order.ransack(params[:q])
        @orders = @q.result.in_state(:paid, :preparing).sorted.includes(:order_items, :order_transitions).page(params[:page]).per(15)
        render :index
      end

      def failed
        @q = Order.ransack(params[:q])
        @orders = @q.result.in_state(:failed).sorted.includes(:order_items, :order_transitions).page(params[:page]).per(15)
        render :index
      end

      def show
        @order = Order.includes(order_items: :orderable).find(params[:id])
        add_breadcrumb @order.number || 'Concept'
      end

      def edit
        @order = Order.find(params[:id])
        add_breadcrumb @order.number, spina.shop_admin_order_path(@order)
        add_breadcrumb t('spina.edit')
      end

      def update
        @order = Order.find(params[:id])
        if @order.update_attributes!(order_params)
          redirect_to spina.shop_admin_order_path(@order)
        else
          render :edit
        end
      end

      def transition
        @orders = Order.where(id: params[:order_ids])
        if params[:transition_to] == "preparing_and_shipped"
          @orders.each do |order|
            order.transition_to("preparing", user: current_spina_user.name, ip_address: request.remote_ip)
            order.transition_to("shipped", user: current_spina_user.name, ip_address: request.remote_ip)
          end
        else
          @orders.each do |order|
            order.transition_to(params[:transition_to], user: current_spina_user.name, ip_address: request.remote_ip)
          end
        end

        if params[:transition_to] == "preparing"
          flash[:success] = t('spina.shop.orders.start_preparing_success_html')
        elsif params[:transition_to] == "shipping"
          flash[:success] = t('spina.shop.orders.ship_order_success_html')
        else
          flash[:success] = t('spina.shop.orders.start_preparing_and_ship_success_html')
        end
        redirect_back fallback_location: spina.shop_admin_orders_path
      end

      private

        def order_params
          params.require(:order).permit!
        end

        def set_breadcrumbs
          add_breadcrumb Order.model_name.human(count: 2), spina.shop_admin_orders_path
        end
    end
  end
end