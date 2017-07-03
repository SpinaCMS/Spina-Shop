module Spina::Shop
  class DeallocateStock

    def initialize(order)
      @order = order
    end

    def deallocate
      # Delete StockLevelAdjustments
      StockLevelAdjustment.where(order_item: @order.order_items).delete_all

      # Cache all products involved
      @order.products.each(&:cache_stock_level)
    end

  end
end
