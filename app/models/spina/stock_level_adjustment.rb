module Spina
  class StockLevelAdjustment < ApplicationRecord
    belongs_to :product_item
    belongs_to :order_item, optional: true

    validates :adjustment, presence: true

    after_save :cache_product_averages

    private

      def cache_product_averages
        product_item.product.save
      end
  end
end