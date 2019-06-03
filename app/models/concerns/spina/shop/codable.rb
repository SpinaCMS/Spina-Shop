require 'active_support/concern'

module Spina::Shop
  module Codable
    extend ActiveSupport::Concern

    included do
      before_validation :generate_unique_code, if: -> { code.blank? }
    end

    def readable_code
      code.size > 3 ? code.insert(4, ' - ') : code
    end

    private

      # Generate a pretty and readable code with distinct characters
      def generate_unique_code(size: 8)
        begin
          charset = %w{2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
          self['code'] = (0...size).map{charset.to_a[SecureRandom.random_number(charset.size)]}.join
        end while GiftCard.exists?(code: self['code']) || Discount.exists?(code: self['code'])
      end

  end
end