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

    def stock_enabled?
      false
    end

    # 0 means no limit
    def limit_per_order
      0
    end

    # No product images
    def product_images
      []
    end

    # Calculate the price based on this order
    def price_for_order(order)
      price
    end
  end
end