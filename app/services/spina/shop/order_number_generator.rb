module Spina::Shop
  class OrderNumberGenerator

    def self.generate!
      sequence = NumberSequence.by_name('orders')
      sequence.increment!
    end

  end
end