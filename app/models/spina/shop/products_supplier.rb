module Spina::Shop
  class ProductsSupplier < ApplicationRecord
    belongs_to :product
    belongs_to :supplier
  end
end