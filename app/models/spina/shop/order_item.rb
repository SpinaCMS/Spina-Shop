module Spina::Shop
  class OrderItem < ApplicationRecord
    attr_accessor :validate_stock

    belongs_to :order
    belongs_to :orderable, polymorphic: true

    belongs_to :parent, class_name: "Spina::Shop::OrderItem", optional: true
    has_many :children, class_name: "Spina::Shop::OrderItem", foreign_key: :parent_id, dependent: :destroy

    has_many :stock_level_adjustments, dependent: :nullify # Don't destroy the stock level adjustments automatically if an order is destroyed

    validates :unit_price, :unit_cost_price, :tax_rate, :weight, presence: true, if: -> { order.try(:received?) }
    validates :quantity, presence: true, numericality: {greater_than: 0, only_integer: true}
    validate :product_not_purchasable
    validate :item_must_be_in_stock, if: -> { validate_stock }

    before_validation :set_quantity_to_limit, if: -> { validate_stock }

    after_save -> { children.each { |c| c.update_attributes(quantity: quantity) }}

    scope :ordered, -> { order(:created_at) }
    scope :products, -> { where(orderable_type: "Spina::Shop::Product") }
    scope :product_bundles, -> { where(orderable_type: "Spina::Shop::ProductBundle") }
    scope :custom_products, -> { where(orderable_type: "Spina::Shop::CustomProduct") }
    scope :roots, -> { where(parent_id: nil) }

    accepts_nested_attributes_for :orderable

    def unit_price
      read_attribute(:unit_price) || orderable.price_for_order(order) || BigDecimal(0)
    end

    def unit_cost_price
      read_attribute(:unit_cost_price) || orderable.cost_price || BigDecimal(0)
    end

    def total_cost_price
      unit_cost_price * quantity
    end

    def tax_rate
      read_attribute(:tax_rate) || orderable.tax_group.tax_rate_for_order(order) || BigDecimal(0)
    end

    # Discount as amount
    def discount_amount
      read_attribute(:discount_amount) || order.discount&.discount_for_order_item(self) || Discount.auto.first_eligible(order)&.discount_for_order_item(self) || BigDecimal(0)
    end

    def weight
      read_attribute(:weight) || orderable.weight || BigDecimal(0)
    end

    def description
      orderable.try(:full_name)
    end

    def total_without_discount
      unit_price * quantity
    end

    def total
      total_without_discount - discount_amount
    end

    def tax_modifier
      (tax_rate + BigDecimal(100)) / BigDecimal(100)
    end

    def total_weight
      quantity * weight
    end

    def in_stock?
      # Custom products are always "in stock"
      if is_custom_product?
        true
      elsif is_product_bundle?
        orderable.bundled_products.all?{|p| product_in_stock?(p.product_id)}
      else
        product_in_stock?(orderable_id)
      end
    end

    def live?
      orderable.live?
    end

    def is_product?
      orderable_type == "Spina::Shop::Product"
    end

    def is_product_bundle?
      orderable_type == "Spina::Shop::ProductBundle"
    end

    def is_custom_product?
      orderable_type == "Spina::Shop::CustomProduct"
    end

    def allocated_stock(product_id)
      -stock_level_adjustments.where(product_id: product_id).sum(:adjustment)
    end

    def unallocated_stock(product_id)
      product_quantity(product_id, quantity) - allocated_stock(product_id)
    end

    def product_quantity(product_id, quantity)
      if is_product_bundle?
        quantity * orderable.bundled_products.find_by(product_id: product_id).try(:quantity).to_i
      else
        orderable_id == product_id ? quantity : 0
      end
    end

    def below_limit?
      limit = orderable.limit_per_order.to_i
      limit == 0 || quantity <= limit
    end

    def products
      is_product_bundle? ? orderable.products : [orderable]
    end

    private

      def product_in_stock?(product_id)
        # Add itself to an array of order items (only check other order items that are product bundles, which might contain the same product_id)
        # If the record isn't persisted yet it won't show up in order.order_items
        order_items = order.order_items.product_bundles.to_a | order.order_items.products.where(orderable_id: product_id) | [self]
        product = Product.find(product_id)
        return true unless product.stock_enabled
        product.stock_level >= order_items.inject(BigDecimal(0)) do |total, order_item|
          order_item.quantity = quantity if order_item == self
          total + order_item.unallocated_stock(product_id)
        end
      end

      def product_not_purchasable
        errors.add(:orderable, "product is not purchasable") if is_product? && orderable.not_purchasable?
      end

      def item_must_be_in_stock
        errors.add(:stock_level, "not sufficient") unless in_stock?
      end

      def set_quantity_to_limit
        self.quantity = orderable.limit_per_order unless below_limit?
      end

  end
end