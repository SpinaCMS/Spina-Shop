module Spina::Shop
  class DeallocateStock

    def initialize(order)
      @order = order
    end

    def deallocate(refund_lines = [])
      deallocate_all and return unless refund_lines.present?
      
      refund_lines.each do |id, params|
        next unless params["stock"] && params["refund"]
        sla = StockLevelAdjustment.find_by(order_item_id: id)
        sla&.update(adjustment: sla.adjustment + params["quantity"].to_i)

        order_item = OrderItem.find_by(id: id)
        order_item&.products&.each(&:cache_stock_level)
      end
    end

    def deallocate_all
      StockLevelAdjustment.where(order_item: @order.order_items).delete_all
      @order.products.each(&:cache_stock_level)
    end

  end
end
