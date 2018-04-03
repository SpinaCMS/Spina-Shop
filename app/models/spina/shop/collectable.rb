module Spina
  module Shop
    class Collectable < ApplicationRecord
      belongs_to :product, inverse_of: :collectables, touch: true
      belongs_to :product_collection
    end
  end
end