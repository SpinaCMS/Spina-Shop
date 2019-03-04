module Spina::Shop
  class InvoiceNumberGenerator

    def self.generate!(order)
      sequence = NumberSequence.by_name('invoices')
      sequence.increment!
    end

  end
end