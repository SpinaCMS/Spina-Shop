module Spina::Shop
  class AllocateStock

    def initialize(order)
      @order = order
    end

    def allocate
      stock_level_adjustments.each do |params|
        product = Product.find(params[:product_id])
        ChangeStockLevel.new(product, params).save
      end
    end

    private

      def stock_level_adjustments
        @order.order_items.map do |order_item|
          if order_item.is_product_bundle?
            order_item.orderable.bundled_products.map do |bundled_product|
              params_for_order_item(order_item, bundled_product.product_id)
            end
          elsif order_item.is_product?
            params_for_order_item(order_item, order_item.orderable_id)
          end
        end.flatten.compact
      end

      def params_for_order_item(order_item, product_id)
        return nil if Product.where(id: product_id, stock_enabled: true).none?
        stock = order_item.unallocated_stock(product_id) * -1
        { order_item_id: order_item.id, product_id: product_id, adjustment: stock, description: "Order #{@order.number}" }
      end

  end
end