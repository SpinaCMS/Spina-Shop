module Spina::Shop
  module CurrentOrder
    extend ActiveSupport::Concern

    included do
      helper_method :logged_in?, :current_customer, :current_customer_account, :current_order

      def logged_in?
        current_customer_account.present?
      end

      def current_customer_account
        @current_customer_account ||= CustomerAccount.find_by(id: session[:customer_account_id])
      end

      def current_customer
        @current_customer ||= current_customer_account&.customer
      end

      def current_order
        @current_order ||= order_by_session || restore_shopping_cart || new_shopping_cart
      end

      private

        def order_by_session
          Order.in_state(:building, :confirming).find_by(id: session[:order_id])
        end

        def restore_shopping_cart
          shopping_cart = find_shopping_cart_by_customer(current_customer)
          set_current_order(shopping_cart)
        end

        def find_shopping_cart_by_customer(customer)
          customer&.orders&.building&.last
        end

        def new_shopping_cart
          Order.new(customer: current_customer, billing_country: current_customer&.country || Country.first, ip_address: request.remote_ip, prices_include_tax: true)
        end

        def login(customer_account)
          # Merge shopping carts if the current shopping cart is persisted (= has any items)
          merge_shopping_carts!(customer_account.customer) if current_order.persisted?
          session[:customer_account_id] = customer_account.id
        end

        # Merge the current order with the last order in your account
        # and set that last order as the new Current.order
        # Don't try to do it the other way round
        # else you'll run into sync issues between sessions
        def merge_shopping_carts!(customer)
          previous_shopping_cart = find_shopping_cart_by_customer(customer)
          return if previous_shopping_cart.nil?

          previous_shopping_cart.merge!(current_order) # Merge cart
          set_current_order(previous_shopping_cart) # Set current order
        end

        def set_current_order(order)
          return if order.nil?
          session[:order_id] = order.id
          @current_order = order
        end
        
    end
  end
end