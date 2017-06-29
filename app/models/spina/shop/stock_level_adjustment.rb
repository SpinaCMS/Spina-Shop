module Spina::Shop
  class StockLevelAdjustment < ApplicationRecord
    belongs_to :product_item
    belongs_to :order_item, optional: true

    scope :additions, -> { where('adjustment > ?', 0) }
    scope :ordered, -> { order(created_at: :desc) }

    validates :adjustment, presence: true

    #after_save :cache_product_item
    #after_destroy :cache_product_item

    def expiration_date
      "#{expiration_month || '–'}/#{expiration_year.to_s.last(2).presence || '–'}"
    end

    private

      def cache_product_item
        product_item.save
      end

  end
end