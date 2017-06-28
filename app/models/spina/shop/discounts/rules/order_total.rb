module Spina::Shop
  module Discounts
    module Rules
      class OrderTotal < DiscountRule
        preferences :total

        validates :total, presence: true, numericality: true

        def eligible?(order_item)
          # order_item.order.order_total >= total
          true
        end

      end
    end
  end
end