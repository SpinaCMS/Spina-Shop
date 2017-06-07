module Spina::Shop
  class InvoiceLine < ApplicationRecord
    belongs_to :invoice

    def total
      quantity * unit_price
    end

    def tax_modifier
      (tax_rate + BigDecimal(100)) / BigDecimal(100)
    end
  end
end