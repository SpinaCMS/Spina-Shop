module Spina::Shop
  class OrderItem < ApplicationRecord
    attr_accessor :validate_stock

    belongs_to :order
    belongs_to :orderable, polymorphic: true

    has_many :stock_level_adjustments, dependent: :nullify # Don't destroy the stock level adjustments automatically if an order is destroyed

    validates :unit_price, :unit_cost_price, :tax_rate, :weight, presence: true, if: -> { order.try(:received?) }
    validate :item_must_be_in_stock, if: -> { validate_stock }
    validates :order_id, uniqueness: {scope: [:orderable_id, :orderable_type]}

    before_validation :set_quantity_to_limit, if: -> { validate_stock }

    scope :ordered, -> { order(:created_at) }

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
      read_attribute(:discount_amount) || order.discount.try(:discount_for_order_item, self) || BigDecimal(0)
    end

    def weight
      read_attribute(:weight) || orderable.weight || BigDecimal(0)
    end

    def description
      orderable.try(:name)
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
      if is_product_bundle?
        orderable.bundled_products.all?{|p| product_in_stock?(p.product_id)}
      else
        product_in_stock?(orderable_id)
      end
    end

    def is_product_bundle?
      orderable_type == "Spina::Shop::ProductBundle"
    end

    def allocated_stock(product_id)
      -stock_level_adjustments.where(product_id: product_id).sum(:adjustment)
    end

    def unallocated_stock(product_id)
      multiplier = if is_product_bundle? 
        orderable.bundled_products.find_by(product_id: product_id).try(:quantity).to_i 
      else
        orderable_id == product_id ? 1 : 0
      end
      quantity * multiplier - allocated_stock(product_id)
    end

    def below_limit?
      limit = orderable.limit_per_order.to_i
      limit == 0 || quantity <= limit
    end

    private

      def product_in_stock?(product_id)
        # Add itself to an array of order items 
        # If the record isn't persisted yet it won't show up in order.order_items
        order_items = order.order_items.to_a | [self]
        product = Product.find(product_id)
        return true unless product.stock_enabled
        product.stock_level >= order_items.inject(BigDecimal(0)) do |total, order_item|
          order_item.quantity = quantity if order_item == self
          total + order_item.unallocated_stock(product_id)
        end
      end

      def item_must_be_in_stock
        errors.add(:stock_level, "not sufficient") unless in_stock?
      end

      def set_quantity_to_limit
        self.quantity = orderable.limit_per_order unless below_limit?
      end

  end
end