module Spina::Shop
  class Order < ApplicationRecord

    def order_total
      return @order_total if defined? @order_total
      @order_total = order_items.inject(BigDecimal(0)) { |t, i| t + i.total }
    end

    def order_total_excluding_tax
      if prices_include_tax
        order_items.inject(BigDecimal(0)) { |t, i| t + (i.total / i.tax_modifier).round(2) }
      else
        order_total
      end
    end

    def order_total_including_tax
      order_total_excluding_tax + tax_amount
    end

    def delivery_price
      return @delivery_price if defined? @delivery_price
      @delivery_price = read_attribute(:delivery_price) || delivery_option.try(:price_for_order, self) || BigDecimal(0)
    end

    def delivery_tax_rate
      return @delivery_tax_rate if defined? @delivery_tax_rate
      @delivery_tax_rate = read_attribute(:delivery_tax_rate) || delivery_option.try(:tax_group).try(:tax_rate_for_order, self) || BigDecimal(0)
    end

    def gift_card_amount
      return @gift_card_amount if defined? @gift_card_amount
      @gift_card_amount = read_attribute(:gift_card_amount) || gift_card.try(:amount_for_order, self) || BigDecimal(0)
    end

    def billing_first_name
      first_name
    end

    def billing_last_name
      last_name
    end

    # Total of the order
    def total
      if prices_include_tax
        order_total + delivery_price
      else
        order_total_excluding_tax + tax_amount + delivery_price
      end
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