module Spina::Shop
  class BundledProduct < ApplicationRecord
    belongs_to :product
    belongs_to :product_bundle
    
    validates :product, uniqueness: {scope: :product_bundle}
  end
end