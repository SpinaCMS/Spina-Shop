module Spina
  module Shop
    module ViewHelpers

      def to_process_order_count
        @to_process_order_count ||= Order.to_process.count
      end

      def unapproved_shop_reviews_count
        @unapproved_shop_reviews_count ||= ShopReview.where(approved: false).count
      end

    end
  end
end