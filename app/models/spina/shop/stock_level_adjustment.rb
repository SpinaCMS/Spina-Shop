module Spina::Shop
  class StockLevelAdjustment < ApplicationRecord
    belongs_to :product
    belongs_to :order_item, optional: true

    scope :additions, -> { where('adjustment > ?', 0) }
    scope :ordered, -> { order(created_at: :desc) }

    validates :adjustment, presence: true

    after_save :cache_product
    after_destroy :cache_product

    def expiration_date
      "#{expiration_month || '–'}/#{expiration_year.to_s.last(2).presence || '–'}"
    end

    private

      # TODO: Extract into service object
      def cache_product
        product.save
      end

  end
end