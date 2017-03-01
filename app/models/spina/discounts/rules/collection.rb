module Spina
  module Discounts
    module Rules
      class Collection < DiscountRule
        preferences :collection_id

        def eligible?(order_item)
          true
        end

      end
    end
  end
end