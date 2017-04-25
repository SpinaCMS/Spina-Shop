module Spina
  class ProductBundle < ApplicationRecord
    belongs_to :tax_group
    belongs_to :sales_category

    has_many :product_images, dependent: :destroy
    
    has_many :bundled_product_items, dependent: :destroy
    has_many :product_items, through: :bundled_product_items

    has_many :in_stock_reminders, as: :orderable, dependent: :destroy

    has_many :order_items, as: :orderable

    accepts_nested_attributes_for :bundled_product_items, :product_images, allow_destroy: true
    accepts_attachments_for :product_images, append: true

    def description
      short_description
    end

    def short_description
      name
    end

    def original_price
      bundled_product_items.inject(BigDecimal(0)){|t, i| t + i.product_item.price * i.quantity}
    end

    def stock_level
      bundled_product_items.map{|b| (b.product_item.stock_level / b.quantity).floor}.min
    end

    def in_stock?
      stock_level > 0
    end

    def weight
      bundled_product_items.inject(BigDecimal(0)){|t, i| t + i.product_item.weight * i.quantity}
    end

    def cost_price
      bundled_product_items.inject(BigDecimal(0)){|t, i| t + i.product_item.cost_price * i.quantity}
    end
  end
end