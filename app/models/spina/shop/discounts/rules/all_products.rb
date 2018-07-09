module Spina::Shop
  module Discounts
    module Rules
      class AllProducts < DiscountRule

        def eligible?(order_item)
          true
        end

      end
    end
  end
end