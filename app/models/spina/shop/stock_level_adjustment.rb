module Spina::Shop
  class StockLevelAdjustment < ApplicationRecord
    belongs_to :product, touch: true
    belongs_to :order_item, optional: true

    scope :additions, -> { where('adjustment > ?', 0) }
    scope :sales, -> { where.not(order_item_id: nil).where('adjustment < ?', 0) }
    scope :ordered, -> { order(created_at: :desc) }
    scope :reserved, -> { joins(order_item: :order).where(spina_shop_orders: {ready_for_pickup_at: nil, shipped_at: nil, picked_up_at: nil, refunded_at: nil}) }

    validates :adjustment, presence: true
    
    def expiration_date
      "#{expiration_month || '–'}/#{expiration_year.to_s.last(2).presence || '–'}"
    end

  end
end