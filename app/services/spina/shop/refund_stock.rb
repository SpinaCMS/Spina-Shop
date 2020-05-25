module Spina::Shop
  class RefundStock < AllocateStock

    def allocate(refund_lines = [])
      @refund_lines = refund_lines
      stock_level_adjustments.each do |params|
        product = Product.find(params[:product_id])
        ChangeStockLevel.new(product, params).save
      end
    end

    private

      def params_for_order_item(order_item, product_id)
        quantity = get_quantity(order_item)
        return nil if quantity.zero?
        return nil if Product.where(id: product_id, stock_enabled: true).none?
        stock = order_item.product_quantity(product_id, quantity)
        { order_item_id: order_item.id, product_id: product_id, adjustment: stock, category: @category, description: "Refund #{@order.number}" }
      end

      def get_quantity(order_item)
        return order_item.quantity unless @refund_lines.present?
        refund_line = @refund_lines[order_item.id.to_s]
        refund_line["refund"] && refund_line["stock"] ? refund_line["quantity"].to_i : 0
      end

  end
end