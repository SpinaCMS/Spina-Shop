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

      def confirm
        @order = Order.find(params[:id])
        @order.transition_to!(:confirming, user: current_spina_user.name, ip_address: request.remote_ip)
        @order.transition_to!(:received, user: current_spina_user.name, ip_address: request.remote_ip)
        redirect_to spina.shop_admin_order_path(@order)
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
        @orders = Order.confirmed.includes(:order_items, :order_transitions).sorted
        filter_orders
      end

      def to_process
        @orders = Order.in_state(:paid, :preparing).includes(:order_items, :order_transitions).sorted
        filter_orders
        render :index
      end

      def failed
        @orders = Order.in_state(:failed).includes(:order_items, :order_transitions).sorted
        filter_orders
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

      private

        def advanced_filters
          params[:advanced_filters] || Hash.new
        end

        def filter_orders        
          # Store
          @orders = @orders.where(store_id: advanced_filters[:store_id]) if advanced_filters[:store_id].present?

          # Date range
          start_date = Date.parse(advanced_filters[:received_at_gteq].presence || "01-01-2000")
          end_date = Date.parse(advanced_filters[:received_at_lteq].presence || "31-12-3000")
          @orders = @orders.where(received_at: start_date..end_date)

          # Search
          @orders = @orders.search(params[:search]) if params[:search].present?

          # Totaal
          @orders_count = @orders.count
          @advanced_filter = advanced_filters.values.any?(&:present?)

          # Pagination
          @orders = @orders.page(params[:page]).per(15)
        end

        def order_params
          params.require(:order).permit!
        end

        def set_breadcrumbs
          add_breadcrumb Order.model_name.human(count: 2), spina.shop_admin_orders_path
        end
    end
  end
end