module Spina
  class DiscountsOrder < ApplicationRecord
    belongs_to :discount
    belongs_to :order
  end
end