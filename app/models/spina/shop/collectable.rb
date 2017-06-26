module Spina
  module Shop
    class Collectable < ApplicationRecord
      belongs_to :product
      belongs_to :product_collection
    end
  end
end