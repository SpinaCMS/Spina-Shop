module Spina::Shop
  module Admin
    class OrdersController < AdminController
      before_action :set_breadcrumbs

      def new
        @order = Order.new
        add_breadcrumb t('spina.shop.orders.new')
      end

      def create
        @order = Order.new(order_params.merge(manual_entry: true))
        @order.validate_details = true
        if @order.save
          redirect_to spina.shop_admin_order_path(@order)
        else
          add_breadcrumb t('spina.shop.orders.new')
          render :new
        end
      end

      def destroy
        @order = Order.find(params[:id])
        @order.destroy if @order.building?
        redirect_to spina.shop_admin_orders_path
      end
      
      def transition
        @order = Order.find(params[:id])        
        @order.transition_to(params[:transition_to], user: current_spina_user.name, ip_address: request.remote_ip)
        redirect_to spina.shop_admin_order_path(@order)
      end

      # def confirm
      #   @order = Order.find(params[:id])
      #   @order.transition_to(:confirming, user: current_spina_user.name, ip_address: request.remote_ip)
      #   @order.transition_to(:received, user: current_spina_user.name, ip_address: request.remote_ip)
      #   if @order.errors.any?
      #     flash[:alert] = t("spina.shop.orders.confirm_failed")
      #     flash[:alert_small] = @order.errors.full_messages.join("<br />")
      #   end
      #   redirect_to spina.shop_admin_order_path(@order)
      # end

      # def cancel
      #   @order = Order.find(params[:id])
      #   @order.transition_to!(:cancelled, user: current_spina_user.name, ip_address: request.remote_ip)
      #   redirect_to spina.shop_admin_order_path(@order)
      # end
# 
#       def receive
#         @order = Order.find(params[:id])
#         @order.transition_to!(:received, user: current_spina_user.name, ip_address: request.remote_ip)
#         redirect_to spina.shop_admin_order_path(@order)
#       end
# 
#       def pay
#         @order = Order.find(params[:id])
#         @order.transition_to!(:paid, user: current_spina_user.name, ip_address: request.remote_ip)
#         redirect_to spina.shop_admin_order_path(@order)
#       end
#       
#       def ready_for_shipment
#         @order = Order.find(params[:id])
#         @order.transition_to!(:ready_for_shipment, user: current_spina_user.name, ip_address: request.remote_ip)
#         redirect_to spina.shop_admin_order_path(@order)
#       end
# 
#       def ready_for_pickup
#         @order = Order.find(params[:id])
#         @order.transition_to!(:ready_for_pickup, user: current_spina_user.name, ip_address: request.remote_ip)
#         redirect_to spina.shop_admin_order_path(@order)
#       end

      # def order_picked_up
      #   @order = Order.find(params[:id])
      #   @order.transition_to!(:picked_up, user: current_spina_user.name, ip_address: request.remote_ip)
      #   redirect_to spina.shop_admin_order_path(@order)
      # end

      # def delivered
      #   @order = Order.find(params[:id])
      #   @order.transition_to!(:delivered, user: current_spina_user.name, ip_address: request.remote_ip)
      #   redirect_to spina.shop_admin_order_path(@order)
      # end

      def index
        orders = Order.confirmed.includes(:order_items, :order_transitions, :delivery_option, :store).sorted
        
        if params[:query].present?
          orders = orders.search(params[:query])
        end
        
        if params[:status].present?
          orders = orders.in_state(params[:status])
        end
        
        if params[:order].present?
          orders = orders.reorder(params[:order])
        end
        
        @orders = orders.page(params[:page]).per(25)
      end

      def concepts
        @orders = Spina::Shop::Order.concept.includes(:order_items, :order_transitions).order(created_at: :desc).page(params[:page]).per(50)
        render :index
      end

      def duplicate
        @order = Order.find(params[:id])
        @duplicate = DuplicateOrder.new(@order).duplicate!
        redirect_to spina.shop_admin_order_path(@duplicate)
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
        if @order.update!(order_params)
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
          
          # Discount
          if advanced_filters[:discount_id].present?
            discount = Discount.find(advanced_filters[:discount_id])
            @orders = @orders.joins(:discount).where(spina_shop_discounts: {id: discount.id})
          end
          
          # Current state
          if advanced_filters[:current_state].present?
            @orders = @orders.in_state(advanced_filters[:current_state].to_sym)
          end
          
          if advanced_filters[:order].present?
            @orders = @orders.reorder(advanced_filters[:order])
          end
          
          if advanced_filters[:billing_country_id].present?
            @orders = @orders.where(billing_country_id: advanced_filters[:billing_country_id])
          end

          # Date range
          if advanced_filters[:received_at_gteq].present? || advanced_filters[:received_at_lteq].present?
            start_date = Date.parse(advanced_filters[:received_at_gteq].presence || "01-01-2000")
            end_date = Date.parse(advanced_filters[:received_at_lteq].presence || "31-12-3000")
            @orders = @orders.where(received_at: start_date..end_date)
          end

          # POS
          if advanced_filters[:pos].present?
            @orders = @orders.where(pos: advanced_filters[:pos])
          end

          # Search
          if params[:search].present?
            params[:search].gsub!(/\A0+/, "")
            @orders = @orders.search(params[:search])
          end

          # Totaal
          @orders_count = @orders.count
          @advanced_filter = advanced_filters.values.any?(&:present?)

          # Pagination
          @orders = @orders.page(params[:page]).per(100)
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