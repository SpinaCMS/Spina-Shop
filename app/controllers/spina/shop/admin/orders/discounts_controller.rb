module Spina::Shop
  module Admin
    module Orders
      class DiscountsController < AdminController
        before_action :set_order
        
        def edit
        end
        
        def update
          discount = Discount.active.find_by(code: params.dig(:order, :code))
          @order.update(discount: discount)
          redirect_to spina.shop_admin_order_path(@order)
        end
        
        private
        
          def set_order
            @order = Order.in_state(:building).find(params[:order_id])
          end
        
      end
    end
  end
end