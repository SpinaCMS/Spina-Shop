module Spina
  class DiscountRule < ApplicationRecord
    include Spina::Preferable
    
    belongs_to :discount

    def eligible?(order_item)
      true
    end

  end
end