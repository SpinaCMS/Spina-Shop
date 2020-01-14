module Spina::Shop
  module Admin
    module Orders
      class RefundsController < AdminController
        before_action :set_order

        def new
          @sales_invoice = @order.sales_invoice
        end

        def create
          render :choose_lines and return if not_the_entire_order?

          @order.transaction do
            @order.update!(refund_params)
            @order.transition_to!(:refunded, refund_transition_params)
          end

          redirect_to spina.shop_admin_order_path(@order)
        end

        private

          def set_order
            @order = Order.find(params[:order_id])
          end

          def not_the_entire_order?
            params[:entire_order].blank? && params[:refund_lines].blank?
          end

          def refund_params
            params.permit(:refund_reason, :refund_method)
          end

          def refund_transition_params
            params.permit(:entire_order, :deallocate_stock, :refund_delivery_costs, refund_lines: [:id, :refund, :quantity, :stock, :unit_price]).merge(user: current_spina_user.name, ip_address: request.remote_ip)
          end

      end
    end
  end
end