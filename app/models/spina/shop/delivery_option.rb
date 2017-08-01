module Spina::Shop
  class DeliveryOption < ApplicationRecord
    belongs_to :tax_group
    belongs_to :sales_category

    has_many :orders, dependent: :restrict_with_exception

    def price_for_order(order)
      return price if price_includes_tax == order.prices_include_tax

      # Get tax rate
      tax_rate = tax_group.tax_rate_for_order(order)
      tax_modifier = (tax_rate + BigDecimal(100)) / BigDecimal(100)

      # Calculate unit price based on tax modifier
      delivery_price = price_includes_tax ? price / tax_modifier : price * tax_modifier

      # Round to two decimals using bankers' rounding
      return delivery_price.round(2, :half_even)
    end

    # You probably want to override this method to return a realistic date
    def soonest_delivery_date_for_order(order)
      Date.today
    end

  end
end