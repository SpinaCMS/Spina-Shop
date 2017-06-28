module Spina
  module Shop
    class PriceException < ApplicationRecord
      belongs_to :product_item
      belongs_to :exceptionable, polymorphic: true
    end
  end
end