module Spina::Shop
  class Order < ApplicationRecord
    def sub_total
      if prices_include_tax
        order_items.inject(BigDecimal(0)) { |t, i| t + (i.total / i.tax_modifier).round(2) }
      else
        order_items.inject(BigDecimal(0)) { |t, i| t + i.total }
      end
    end

    def sub_total_including_tax
      sub_total + tax_amount
    end

    def delivery_price
      read_attribute(:delivery_price) || delivery_option.try(:price_for_order, self) || BigDecimal(0)
    end

    def delivery_tax_rate
      read_attribute(:delivery_tax_rate) || delivery_option.try(:tax_group).try(:tax_rate_for_order, self) || BigDecimal(0)
    end

    def gift_card_amount
      read_attribute(:gift_card_amount) || gift_card.try(:amount_for_order, self) || BigDecimal(0)
    end

    def billing_first_name
      first_name
    end

    def billing_last_name
      last_name
    end

    # Total of the order
    def total
      sub_total + tax_amount + delivery_price
    end

    def total_owed
      total - gift_card_amount
    end

    def nothing_owed?
      paid? || total_owed == BigDecimal(0)
    end

    def tax_amount
      tax_amount_by_rates.inject(BigDecimal(0)) { |t, r| t + r[1][:tax_amount] }
    end

    def tax_amount_by_rates
      if prices_include_tax
        rates = order_items.inject({}) do |h, item|
          rate = h[item.tax_rate] ||= { tax_amount: BigDecimal(0), total: BigDecimal(0) }
          rate[:total] += (item.total / item.tax_modifier).round(2)
          rate[:tax_amount] += item.total - (item.total / item.tax_modifier).round(2)
          h
        end
      else
        rates = order_items.inject({}) do |h, item|
          rate = h[item.tax_rate] ||= { tax_amount: BigDecimal(0), total: BigDecimal(0) }
          rate[:total] += item.total
          rate[:tax_amount] += (item.total * (BigDecimal(item.tax_rate) / BigDecimal(100))).round(2)
          h
        end
      end

      rates.sort{|x, y| y[0] <=> x[0]}.to_h
    end

  end
end