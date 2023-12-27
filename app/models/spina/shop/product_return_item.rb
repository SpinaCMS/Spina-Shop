module Spina::Shop
  class ProductReturnItem < ApplicationRecord
    belongs_to :product
    belongs_to :product_return
    
    # Quantity should be at least 1, but returned_quantity can be 0
    validates :quantity, numericality: {greater_than_or_equal_to: 1}
    validates :returned_quantity, numericality: {greater_than_or_equal_to: 0}
  end
end
