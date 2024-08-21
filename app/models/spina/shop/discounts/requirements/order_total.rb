module Spina::Shop
  module Discounts
    module Requirements
      class OrderTotal < DiscountRequirement
        preferences :total, :total_max

        validates :total, presence: true, numericality: true

        def eligible?(order)
          order.order_total_without_discount.in? BigDecimal(total)..maximum
        end

        def maximum
          total_max.present? ? BigDecimal(total_max) : BigDecimal("Infinity")
        end

      end
    end
  end
end