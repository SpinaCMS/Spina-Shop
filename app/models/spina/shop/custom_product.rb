module Spina::Shop
  class CustomProduct < ApplicationRecord
    has_one :order_item, dependent: :restrict_with_exception

    belongs_to :tax_group, optional: false
    belongs_to :sales_category, optional: false

    validates :name, :price, presence: true

    def to_s
      name
    end

    def full_name
      name
    end

    def weight
      0
    end

    def cost_price
      0
    end

    def must_be_of_age_to_buy?
      false
    end

    # Calculate the price based on this order
    def price_for_order(order)
      price
    end
  end
end