module Spina::Shop
  class GiftCardsOrder < ApplicationRecord
    belongs_to :gift_card
    belongs_to :order
  end
end
