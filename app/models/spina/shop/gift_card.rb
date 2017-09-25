module Spina::Shop
  class GiftCard < ApplicationRecord
    before_create :generate_unique_code
    before_create :set_remaining_balance

    scope :available, -> { where('remaining_balance > ?', BigDecimal(0)).where('expires_at > ?', Date.today) }

    has_many :gift_cards_orders
    has_many :orders, through: :gift_cards_orders, dependent: :restrict_with_exception

    validates :expires_at, :value, :remaining_balance, presence: true
    validates :value, numericality: {greater_than: 0}

    def amount_for_order(order)
      [remaining_balance, order.total].min
    end

    def readable_code
      code.insert(4, ' - ')
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

      # Generate a pretty and readable code with distinct characters
      def generate_unique_code(size: 8)
        begin
          charset = %w{2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
          self['code'] = (0...size).map{charset.to_a[SecureRandom.random_number(charset.size)]}.join
        end while GiftCard.exists?(code: self['code'])
      end

      def set_remaining_balance
        self.remaining_balance = value
      end

  end
end