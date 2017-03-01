module Spina
  module Discounts
    module Rules
      class AllOrders < DiscountRule

        def eligible?(order_item)
          true
        end

      end
    end
  end
end