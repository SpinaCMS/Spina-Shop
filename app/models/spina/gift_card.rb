module Spina
  class GiftCard < ApplicationRecord
    before_create :generate_unique_code

    has_many :gift_cards_orders
    has_many :orders, through: :gift_cards_orders, dependent: :restrict_with_exception

    validates :code, :expires_at, :value, presence: true
    validates :code, uniqueness: true

    private

      # Generate a pretty and readable code with distinct characters
      def generate_unique_code(size: 8)
        begin
          charset = %w{2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
          self['code'] = (0...size).map{charset.to_a[SecureRandom.random_number(charset.size)]}.join
        end while GiftCard.exists?(code: self['code'])
      end

  end
end