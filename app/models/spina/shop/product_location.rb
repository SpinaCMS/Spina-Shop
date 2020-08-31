module Spina::Shop
  class ProductLocation < ApplicationRecord
    belongs_to :product
    belongs_to :location
  end
end
