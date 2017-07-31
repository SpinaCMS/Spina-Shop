module Spina::Shop
  class ProductBundle < ApplicationRecord
    belongs_to :tax_group
    belongs_to :sales_category

    has_many :product_images, dependent: :destroy
    
    has_many :bundled_products, dependent: :destroy
    has_many :products, through: :bundled_products

    has_many :in_stock_reminders, as: :orderable, dependent: :destroy

    has_many :order_items, as: :orderable

    accepts_nested_attributes_for :bundled_products, :product_images, allow_destroy: true
    accepts_attachments_for :product_images, append: true

    # Calculate the price based on this order
    def price_for_order(order)
      price
    end

    def description
      short_description
    end

    def short_description
      name
    end

    def original_price
      bundled_products.inject(BigDecimal(0)){|t, i| t + i.product.price * i.quantity}
    end

    def stock_level
      bundled_products.map{|b| (b.product.stock_level / b.quantity).floor}.min
    end

    def in_stock?
      stock_level > 0
    end

    def weight
      bundled_products.inject(BigDecimal(0)){|t, i| t + (i.product.weight || BigDecimal.new(0)) * i.quantity}
    end

    def cost_price
      bundled_products.inject(BigDecimal(0)){|t, i| t + (i.product.cost_price || BigDecimal.new(0)) * i.quantity}
    end
  end
end