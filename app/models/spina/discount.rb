module Spina
  class Discount < ApplicationRecord
    include Spina::Preferable

    scope :active, -> { where('starts_at <= :today AND (expires_at IS NULL OR expires_at >= :today)', today: Date.today) }

    has_one :discount_rule
    has_one :discount_action

    has_many :discounts_orders
    has_many :orders, through: :discounts_orders

    validates :code, uniqueness: true

    accepts_nested_attributes_for :discount_rule, :discount_action

    def description
      "10% korting op alle producten"
    end

    def active?
      starts_at <= Date.today && (expires_at.blank? || expires_at >= Date.today)
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