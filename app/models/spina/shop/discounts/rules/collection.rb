module Spina::Shop
  module Discounts
    module Rules
      class Collection < DiscountRule
        preferences :product_collection_id

        def eligible?(order_item)
          order_item.is_product? && order_item.orderable&.product_collection_ids&.include?(product_collection_id.to_i)
        end

      end
    end
  end
end