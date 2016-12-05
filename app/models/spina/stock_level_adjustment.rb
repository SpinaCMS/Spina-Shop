module Spina
  class StockLevelAdjustment < ApplicationRecord
    belongs_to :product_item
    belongs_to :order_item, optional: true

    validates :adjustment, presence: true
  end
end