module Spina::Shop
  class OrderedSupply < ApplicationRecord
    self.table_name = "spina_shop_ordered_supply"

    belongs_to :supply_order
    belongs_to :product

    validates :quantity, presence: true
  end
end