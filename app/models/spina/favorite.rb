module Spina
  class Favorite < ApplicationRecord
    belongs_to :customer
    belongs_to :product

    validates :customer_id, uniqueness: {scope: :product_id}
  end
end