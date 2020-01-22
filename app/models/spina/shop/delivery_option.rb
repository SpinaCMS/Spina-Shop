module Spina::Shop
  class DeliveryOption < ApplicationRecord
    belongs_to :tax_group
    belongs_to :sales_category

    has_many :orders, dependent: :restrict_with_exception

    def price_for_order(order)
      return BigDecimal(0) if free_delivery?(order)
      return price if price_includes_tax == order.prices_include_tax

      # Get tax rate
      price_modifier = tax_group.price_modifier_for_order(order)

      # Calculate unit price based on tax modifier
      delivery_price = price_includes_tax ? price / price_modifier : price * price_modifier

      # Round to two decimals using bankers' rounding
      return delivery_price.round(2, :half_even)
    end

    # You probably want to override this method to return a realistic date
    def soonest_delivery_date_for_order(order)
      Date.today
    end

    def free_delivery?(order)
      order.discount&.free_delivery?(order) || Discount.auto.first_eligible(order)&.free_delivery?(order)
    end

  end
end