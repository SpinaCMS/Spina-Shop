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
      # All giftcards that went before
      total_gift_card_amount_before_this_gift_card = order.gift_cards.where('remaining_balance < :balance OR remaining_balance = :balance AND spina_shop_gift_cards.id < :id', balance: remaining_balance, id: id).sum(:remaining_balance)

      still_open = order.total - total_gift_card_amount_before_this_gift_card
      if still_open > 0
        [still_open, remaining_balance].min
      else
        BigDecimal.new(0)
      end
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