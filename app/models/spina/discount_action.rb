module Spina
  class DiscountAction < ApplicationRecord
    include Spina::Preferable

    belongs_to :discount

    def compute(order_item)
      true
    end
  end
end