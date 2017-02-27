module Spina
  class InvoiceLine < ApplicationRecord
    belongs_to :invoice

    def total_without_discount
      quantity * unit_price
    end

    def total
      total_without_discount - discount_amount
    end

    def tax_modifier
      (tax_rate + BigDecimal(100)) / BigDecimal(100)
    end
  end
end