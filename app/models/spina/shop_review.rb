module Spina
  class ShopReview < ApplicationRecord
    belongs_to :order, optional: true
    belongs_to :customer, optional: true
  end
end