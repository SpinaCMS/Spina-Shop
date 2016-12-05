module Spina
  class Invoice < ApplicationRecord
    belongs_to :order
    belongs_to :customer
    belongs_to :country

    has_many :invoice_lines, dependent: :destroy

    def sub_total
      if prices_include_tax
        invoice_lines.inject(BigDecimal(0)) { |t, i| t + i.total / i.tax_modifier }
      else
        invoice_lines.inject(BigDecimal(0)) { |t, i| t + i.total }
      end
    end

    def tax_amount
      tax_amount_by_rates.inject(BigDecimal(0)) { |t, r| t + r[1][:tax_amount] }
    end

    def total
      sub_total + tax_amount
    end

    def tax_amount_by_rates
      if prices_include_tax
        rates = invoice_lines.inject({}) do |h, line|
          rate = h[line.tax_rate] ||= { tax_amount: BigDecimal(0), total: BigDecimal(0) }
          rate[:total] += line.total / line.tax_modifier
          rate[:tax_amount] += line.total - (line.total / line.tax_modifier)
          h
        end
      else
        rates = invoice_lines.inject({}) do |h, line|
          rate = h[line.tax_rate] ||= { tax_amount: BigDecimal(0), total: BigDecimal(0) }
          rate[:total] += line.total
          h
        end

        rates.each do |rate|
          rate[1][:tax_amount] = rate[1][:total] * (BigDecimal(rate[0]) / BigDecimal(100))
        end
      end

      rates.sort{|x, y| y[0] <=> x[0]}.to_h
    end
  end
end