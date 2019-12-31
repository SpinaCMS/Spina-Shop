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
        refund_line = get_refund_line(order_item)
        return nil if Product.where(id: product_id, stock_enabled: true).none?
        return nil if refund_line.nil?
        stock = order_item.product_quantity(product_id, refund_line["quantity"])
        { order_item_id: order_item.id, product_id: product_id, adjustment: stock, description: "Refund #{@order.number}" }
      end

      def get_refund_line(order_item)
        return {refund: true, stock: true, quantity: order_item.quantity} if @refund_lines.empty?
        refund_line = @refund_lines[order_item.id.to_s]
        refund_line["refund"] && refund_line["stock"] ? refund_line : nil
      end

  end
end