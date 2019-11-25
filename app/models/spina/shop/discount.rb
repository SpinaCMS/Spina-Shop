module Spina::Shop
  class Discount < ApplicationRecord
    include Preferable, Codable

    has_one :discount_requirement, inverse_of: :discount
    has_one :discount_rule, inverse_of: :discount
    has_one :discount_action, inverse_of: :discount

    has_many :discounts_orders
    has_many :orders, through: :discounts_orders, dependent: :restrict_with_exception

    validates :code, :description, :starts_at, :discount_rule, :discount_action, :discount_requirement, presence: true
    validates :code, uniqueness: true

    scope :multiple_use, -> { where.not(usage_limit: 1) }
    scope :one_off, -> { where(usage_limit: 1) }
    scope :auto, -> { where(auto: true) }
    scope :active, -> { where('starts_at <= :date AND (expires_at IS NULL OR expires_at >= :date)', date: Date.today) }
    scope :ordered, -> { order("CASE WHEN expires_at IS NULL OR expires_at >= NOW() AND starts_at <= NOW() THEN 0 ELSE 1 END") }

    accepts_nested_attributes_for :discount_rule, :discount_action, :discount_requirement

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

    def order_eligible?(order)
      return true unless discount_requirement
      discount_requirement.eligible?(order)
    end

    def order_item_eligible?(order_item)
      return true unless discount_rule
      discount_rule.eligible?(order_item)
    end

    def discount_for_order_item(order_item)
      return BigDecimal(0) if inactive?
      return BigDecimal(0) unless order_eligible?(order_item.order)
      return BigDecimal(0) unless order_item_eligible?(order_item)
      discount_action.compute(order_item)
    end

    def self.first_eligible(order)
      auto.active.find{ |discount| discount.order_eligible?(order) }
    end

  end
end