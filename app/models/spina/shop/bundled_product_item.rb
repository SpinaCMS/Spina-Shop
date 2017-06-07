module Spina::Shop
  class BundledProductItem < ApplicationRecord
    belongs_to :product_item
    belongs_to :product_bundle
  end
end