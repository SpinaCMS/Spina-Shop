module Spina::Shop
  module CurrentOrder
    extend ActiveSupport::Concern

    included do

      def current_customer
        @current_customer ||= current_customer_account.customer if current_customer_account
      end
      helper_method :current_customer

      def current_customer_account
        @current_customer_account ||= CustomerAccount.where(id: session[:customer_account_id]).first if session[:customer_account_id]
      end
      helper_method :current_customer_account

      def current_order
        @current_order ||= begin
          if has_order?
            @current_order
          else
            order = Order.create(
              customer: current_customer,
              billing_country: current_customer.try(:country) || Country.first,
              ip_address: request.remote_ip,
              prices_include_tax: !current_customer.try(:customer_account).present?
            )
            session[:order_id] = order.id
            order
          end
        end
      rescue ActiveRecord::RecordNotFound
        session[:order_id] = nil
      end
      helper_method :current_order

      def has_order?
        session[:order_id] && @current_order = Order.in_state(:building, :confirming).find_by(id: session[:order_id])
      end
        
    end
  end
end