module Spina::Shop
  class OrderPickItem < ApplicationRecord
    belongs_to :product
    belongs_to :order_item
  end
end
