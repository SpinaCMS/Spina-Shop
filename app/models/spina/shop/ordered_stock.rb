module Spina::Shop
  class OrderedStock < ApplicationRecord
    self.table_name = "spina_shop_ordered_stock"

    belongs_to :stock_order
    belongs_to :product

    validates :quantity, presence: true
  end
end