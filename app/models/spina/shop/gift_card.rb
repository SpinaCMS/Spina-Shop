module Spina::Shop
  class GiftCard < ApplicationRecord
    include Codable

    before_create :set_remaining_balance

    scope :available, -> { where('remaining_balance > ?', BigDecimal(0)).where('expires_at > ?', Date.today) }
    scope :sorted_by_order, -> { order("spina_shop_gift_cards_orders.created_at") }

    has_many :gift_cards_orders
    has_many :orders, through: :gift_cards_orders, dependent: :restrict_with_exception

    validates :expires_at, :value, :remaining_balance, presence: true
    validates :value, numericality: {greater_than: 0}

    def expired?
      expires_at < Date.today
    end

    def status
      if remaining_balance == BigDecimal(0)
        'used'
      elsif expired?
        'expired'
      elsif remaining_balance == value
        'unused'
      else
        'partially_used'
      end
    end

    def used_balance
      value - remaining_balance
    end

    def subtract!(value)
      update!(remaining_balance: remaining_balance - value)
    end

    def add!(value)
      update!(remaining_balance: remaining_balance + value)
    end

    private

      def set_remaining_balance
        self.remaining_balance = value
      end

  end
end