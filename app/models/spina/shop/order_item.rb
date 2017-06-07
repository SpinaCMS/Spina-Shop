module Spina::Shop
  class OrderItem < ApplicationRecord
    attr_accessor :validate_stock

    belongs_to :order
    belongs_to :orderable, polymorphic: true

    has_many :stock_level_adjustments, dependent: :nullify # Don't destroy the stock level adjustments automatically if an order is destroyed

    validates :unit_price, :unit_cost_price, :tax_rate, :weight, presence: true, if: -> { order.try(:received?) }
    validate :item_must_be_in_stock, if: -> { validate_stock }
    validates :order_id, uniqueness: {scope: [:orderable_id, :orderable_type]}

    scope :ordered, -> { order(:created_at) }

    before_save do
      if order.confirmed? && (unit_price_changed? || unit_cost_price_changed? || tax_rate_changed? || discount_amount_changed?)
        cache_pricing
        cache_metadata
      end
    end

    def unit_price
      read_attribute(:unit_price) || orderable.price || BigDecimal(0)
    end

    def unit_cost_price
      read_attribute(:unit_cost_price) || orderable.cost_price || BigDecimal(0)
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
      orderable.description
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
        orderable.bundled_product_items.all?{|p| product_item_in_stock?(p.product_item_id)}
      else
        product_item_in_stock?(orderable_id)
      end
    end

    def allocate_unallocated_stock!
      if is_product_bundle?
        orderable.bundled_product_items.each do |bundled_product|
          create_stock_level_adjustment(bundled_product.product_item_id)
        end
      else
        create_stock_level_adjustment(orderable_id)
      end
    end

    def unallocate_allocated_stock
      stock_level_adjustments.destroy_all
    end

    def cache_pricing!
      cache_pricing
      save!
    end

    def cache_metadata!
      cache_metadata
      save!
    end

    def is_product_bundle?
      orderable_type == "Spina::Shop::ProductBundle"
    end

    def unallocated_stock(product_item_id)
      multiplier = if is_product_bundle? 
        orderable.bundled_product_items.find_by(product_item_id: product_item_id).try(:quantity).to_i 
      else
        orderable_id == product_item_id ? 1 : 0
      end
      quantity * multiplier - allocated_stock(product_item_id)
    end

    private

      def create_stock_level_adjustment(product_item_id)
        if (stock = unallocated_stock(product_item_id)) > 0
          stock_level_adjustments.create!(product_item_id: product_item_id, adjustment: -stock, description: "Bestelling #{order.number}")
        end
      end

      def product_item_in_stock?(product_item_id)
        # Add itself to an array of order items 
        # If the record isn't persisted yet it won't show up in order.order_items
        order_items = order.order_items.to_a | [self]
        product_item = ProductItem.find(product_item_id)
        product_item.stock_level >= order_items.inject(BigDecimal(0)) do |total, order_item|
          order_item.quantity = quantity if order_item == self
          total + order_item.unallocated_stock(product_item.id)
        end
      end

      def allocated_stock(product_item_id)
        -stock_level_adjustments.where(product_item_id: product_item_id).sum(:adjustment)
      end

      def item_must_be_in_stock
        errors.add(:stock_level, "not sufficient") unless in_stock?
      end

      def cache_pricing
        write_attribute :weight, weight
        write_attribute :unit_price, unit_price
        write_attribute :unit_cost_price, unit_cost_price
        write_attribute :tax_rate, tax_rate
        write_attribute :discount_amount, discount_amount
      end

      def cache_metadata
        write_attribute :metadata, {
          tax_code: orderable.tax_group.tax_code_for_order(order),
          sales_category_code: orderable.sales_category.code_for_order(order)
        }
      end

  end
end