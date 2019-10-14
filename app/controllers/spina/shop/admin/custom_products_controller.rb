module Spina::Shop
  module Admin
    class CustomProductsController < AdminController
      before_action :set_order

      def new
        @order_item = @order.order_items.new(orderable: CustomProduct.new)
      end

      def create
        stripped_order_item_params = order_item_params
        custom_product_params = stripped_order_item_params.delete :orderable_attributes
        @order_item = @order.order_items.new(stripped_order_item_params)
        @order_item.orderable = CustomProduct.new(custom_product_params)
        @order_item.save
        redirect_to spina.shop_admin_order_path(@order)
      end

      private

        def set_order
          @order = Order.building.find(params[:order_id])
        end

        def order_item_params
          params.require(:order_item).permit(:quantity, orderable_attributes: [:name, :price, :tax_group_id, :sales_category_id])
        end

    end
  end
end