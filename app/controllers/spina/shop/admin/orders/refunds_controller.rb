module Spina::Shop
  module Admin
    module Orders
      class RefundsController < AdminController
        before_action :set_order

        def new
          @sales_invoice = @order.sales_invoice
        end

        def create
          @order.transaction do
            # Update refund params
            @order.update!(refund_params)

            # Transition to refunded
            @order.transition_to!(:refunded, user: current_spina_user.name, ip_address: request.remote_ip, deallocate_stock_after_refund: params[:deallocate_stock_after_refund] == "1")
          end
          redirect_to spina.shop_admin_order_path(@order)
        end

        private

          def set_order
            @order = Order.find(params[:order_id])
          end

          def refund_params
            params.permit(:refund_reason, :refund_method)
          end

      end
    end
  end
end