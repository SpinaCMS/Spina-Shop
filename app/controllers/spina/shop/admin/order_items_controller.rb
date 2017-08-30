module Spina::Shop
   module Admin
    class OrderItemsController < AdminController
      before_action :set_order

      def new
        @order_item = @order.order_items.build
      end

      def create
        @order_item = @order.order_items.build(order_item_params)
        if @order_item.save
          redirect_to spina.shop_admin_order_path(@order)
        else
          redirect_to spina.shop_admin_order_path(@order)
        end
      end

      def destroy
        @order_item = @order.order_items.find(params[:id])
        @order_item.destroy
        redirect_to spina.shop_admin_order_path(@order)
      end

      private

        def order_item_params
          params.require(:order_item).permit(:orderable_id, :orderable_type, :quantity)
        end

        def set_order
          @order = Order.building.find(params[:order_id])
        end
    end
  end
end