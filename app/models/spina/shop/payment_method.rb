module Spina::Shop
  class PaymentMethod < ApplicationRecord
    belongs_to :tax_group
    belongs_to :sales_category

    has_many :orders, dependent: :restrict_with_exception

    def price_for_order(order)
      return price if price_includes_tax == order.prices_include_tax

      # Get tax rate
      price_modifier = tax_group.price_modifier_for_order(order)

      # Calculate unit price based on tax modifier
      payment_method_price = price_includes_tax ? price / price_modifier : price * price_modifier

      # Round to two decimals using bankers' rounding
      return payment_method_price.round(2, :half_even)
    end

    def to_s
      name
    end
  end
end