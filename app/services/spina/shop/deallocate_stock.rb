module Spina::Shop
  class DeallocateStock

    def initialize(order)
      @order = order
    end

    def deallocate(order_item_params = [])
      deallocate_all and return if order_item_params.empty?
        
      order_item_params.each do |params|
        next unless params["stock"]
        sla = StockLevelAdjustment.find_by(order_item_id: params["id"])
        sla&.update(adjustment: sla.adjustment + params["quantity"].to_i)

        order_item = OrderItem.find_by(id: params["id"])
        order_item&.products&.each(&:cache_stock_level)
      end
    end

    def deallocate_all
      StockLevelAdjustment.where(order_item: @order.order_items).delete_all
      @order.products.each(&:cache_stock_level)
    end

  end
end
