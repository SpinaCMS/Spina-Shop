module Spina::Shop
  class GiftCard < ApplicationRecord
    include Codable

    before_create :set_remaining_balance

    scope :available, -> { where('remaining_balance > ?', BigDecimal(0)).where('expires_at > ?', Date.today) }

    has_many :gift_cards_orders
    has_many :orders, through: :gift_cards_orders, dependent: :restrict_with_exception

    validates :expires_at, :value, :remaining_balance, presence: true
    validates :value, numericality: {greater_than: 0}

    def amount_for_order(order)
      [remaining_balance, order.total].min
    end

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

    private

      def set_remaining_balance
        self.remaining_balance = value
      end

  end
end