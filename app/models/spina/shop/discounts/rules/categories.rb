module Spina::Shop
  module Discounts
    module Rules
      class Categories < DiscountRule
        preferences :product_category_ids

        def eligible?(order_item)
          order_item.is_product? && order_item.orderable&.root&.product_category_id&.to_s&.in?(product_category_ids)
        end

      end
    end
  end
end
