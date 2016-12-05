module Spina
  class InvoiceNumberGenerator

    def self.generate
      sequence = NumberSequence.by_name('invoices')
      sequence.increment!
    end

  end
end