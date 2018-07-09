module Spina::Shop
  module Discounts
    module Requirements
      class AllOrders < DiscountRequirement

        def eligible?(order)
          true
        end

      end
    end
  end
end