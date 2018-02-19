module Spina::Shop
  class AvailableProduct < ApplicationRecord
    belongs_to :product
    belongs_to :store
  end
end
