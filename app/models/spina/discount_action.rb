module Spina
  class DiscountAction < ApplicationRecord
    include Spina::Preferable

    belongs_to :discount

    def compute(order_item)
      true
    end
  end
end

require_dependency "#{File.dirname(__FILE__)}/discounts/actions/percent_off"