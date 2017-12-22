module Spina::Shop
  class Discount < ApplicationRecord
    include Preferable

    has_one :discount_rule, inverse_of: :discount
    has_one :discount_action, inverse_of: :discount

    has_many :discounts_orders
    has_many :orders, through: :discounts_orders

    validates :code, :description, :starts_at, :discount_rule, :discount_action, presence: true
    validates :code, uniqueness: true

    accepts_nested_attributes_for :discount_rule, :discount_action

    def active?
      starts_at <= Date.today && (expires_at.blank? || expires_at >= Date.today) && !usage_limit_reached?
    end

    def usage_limit_reached?
      return false if usage_limit == 0
      orders.confirmed.count >= usage_limit
    end

    def inactive?
      !active?
    end

    def order_item_eligible?(order_item)
      return false if inactive?
      return true unless discount_rule
      discount_rule.eligible?(order_item)
    end

    def discount_for_order_item(order_item)
      return BigDecimal(0) if inactive?
      return BigDecimal(0) unless order_item_eligible?(order_item)
      discount_action.compute(order_item)
    end

  end
end