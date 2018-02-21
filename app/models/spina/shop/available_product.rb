module Spina::Shop
  class AvailableProduct < ApplicationRecord
    belongs_to :product, inverse_of: :available_products, touch: true
    belongs_to :store
  end
end
