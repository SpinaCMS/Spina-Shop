module Spina::Shop
  class OrderedStock < ApplicationRecord
    self.table_name = "spina_shop_ordered_stock"

    belongs_to :stock_order
    belongs_to :product

    validates :quantity, presence: true

    scope :processed, -> { where('received >= quantity') }
    scope :unprocessed, -> { where('received < quantity') }

    def new_product?
      product.stock_level_adjustments.additions.where.not(description: "StockOrder ##{stock_order.id}").none?
    end

  end
end