module Spina
  module Discounts
    module Rules
      class OrderTotal < DiscountRule
        preferences :total

        validates :total, presence: true, numericality: true

        def eligible?(order_item)
          # order_item.order.sub_total_including_tax >= total
          true
        end

      end
    end
  end
end