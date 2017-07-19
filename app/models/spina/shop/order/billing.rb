module Spina::Shop
  class Order < ApplicationRecord

    def order_total
      order_items.inject(BigDecimal(0)) { |t, i| t + i.total }
    end

    def delivery_price
      read_attribute(:delivery_price) || delivery_option.try(:price_for_order, self) || BigDecimal(0)
    end

    def delivery_tax_rate
      read_attribute(:delivery_tax_rate) || delivery_option.try(:tax_group).try(:tax_rate_for_order, self) || BigDecimal(0)
    end

    def delivery_tax_modifier
      (delivery_tax_rate + BigDecimal(100)) / BigDecimal(100)
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
      order_total + delivery_price + (prices_include_tax ? 0 : tax_amount)
    end

    def total_excluding_tax
      total - tax_amount
    end

    def to_be_paid
      total - gift_card_amount
    end

    # Mandatory rounding to 0.05 for cash payments in a store
    def to_be_paid_round
      (to_be_paid * 2).round(1, :half_up) / 2
    end

    def to_be_paid_rounding_difference
      to_be_paid_round - to_be_paid
    end

    def nothing_owed?
      paid? || to_be_paid == BigDecimal(0)
    end

    def tax_amount
      tax_amount_by_rates.inject(BigDecimal(0)) { |t, r| t + r[1][:tax_amount] }
    end

    def tax_amount_by_rates
      items = [order_items]
      items << OpenStruct.new(tax_rate: delivery_tax_rate, tax_modifier: delivery_tax_modifier, total: delivery_price) if delivery_option.present?
      rates = items.flatten.inject({}) do |h, item|
        rate = h[item.tax_rate] ||= { tax_amount: BigDecimal(0), total: BigDecimal(0) }
        if prices_include_tax
          rate[:total] += (item.total / item.tax_modifier).round(2)
          rate[:tax_amount] += item.total - (item.total / item.tax_modifier).round(2)
        else
          rate[:total] += item.total
          rate[:tax_amount] += (item.total * (BigDecimal(item.tax_rate) / BigDecimal(100))).round(2)
        end
        h
      end

      rates.sort{|x, y| y[0] <=> x[0]}.to_h
    end

  end
end