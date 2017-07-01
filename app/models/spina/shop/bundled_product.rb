module Spina::Shop
  class BundledProduct < ApplicationRecord
    belongs_to :product
    belongs_to :product_bundle
  end
end