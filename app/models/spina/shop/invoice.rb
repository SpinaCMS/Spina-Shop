module Spina::Shop
  class Invoice < ApplicationRecord
    belongs_to :order
    belongs_to :customer
    belongs_to :country

    has_many :invoice_lines, dependent: :destroy

    def filename
      "inv_#{invoice_number}.pdf"
    end

    def receiver
      company_name.presence || customer_name
    end

    def sub_total
      if prices_include_tax
        invoice_lines.inject(BigDecimal(0)) { |t, i| t + (i.total / i.tax_modifier).round(2) }
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
          rate[:total] += (line.total / line.tax_modifier).round(2)
          rate[:tax_amount] += line.total - (line.total / line.tax_modifier).round(2)
          h
        end
      else
        rates = invoice_lines.inject({}) do |h, line|
          rate = h[line.tax_rate] ||= { tax_amount: BigDecimal(0), total: BigDecimal(0) }
          rate[:total] += line.total
          rate[:tax_amount] += (line.total * (BigDecimal(line.tax_rate) / BigDecimal(100))).round(2)
          h
        end
      end

      rates.sort{|x, y| y[0] <=> x[0]}.to_h
    end

    def credit?
      total < 0
    end
  end
end