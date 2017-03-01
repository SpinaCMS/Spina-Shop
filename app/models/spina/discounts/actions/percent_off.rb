module Spina
  module Discounts
    module Actions
      class PercentOff < DiscountAction
        
        preferences :percent_off

        validates :percent_off, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100}

        def compute(order_item)
          (order_item.total_without_discount * percent_off.to_i / 100).round(2)
        end

      end
    end
  end
end