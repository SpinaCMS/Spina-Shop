module Spina::Shop
  module Order::Billing
    extend ActiveSupport::Concern

    def order_total
      order_items.inject(BigDecimal(0)) { |t, i| t + i.total }
    end

    def order_total_without_discount
      order_items.inject(BigDecimal(0)) { |t, i| t + i.total_without_discount }
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
      read_attribute(:gift_card_amount) || total_gift_card_amount
    end

    def gift_cards_applied?
      read_attribute(:gift_card_amount).present?
    end

    def total_gift_card_amount
      gift_card_usage_for_order.inject(BigDecimal(0)) { |t, g| t + g[:usage_for_order]}
    end

    def gift_card_usage_for_order
      remaining_total = gift_cards_applied? ? gift_card_amount : total  
      gift_cards.sorted_by_order.map do |gift_card|
        value = [gift_cards_applied? ? gift_card.used_balance : gift_card.remaining_balance, remaining_total].min
        remaining_total = remaining_total - value
        { gift_card: gift_card, usage_for_order: value }
      end
    end

    def apply_gift_cards!
      transaction do
        # Cache total before subtracting from gift cards
        total = total_gift_card_amount
        gift_card_usage_for_order.each{|g| g[:gift_card].subtract!(g[:usage_for_order])}
        update!(gift_card_amount: total)
      end
    end

    def remove_gift_cards!
      transaction do
        gift_card_usage_for_order.each{|g| g[:gift_card].add!(g[:usage_for_order])}
        update!(gift_card_amount: nil)
      end
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
      if vat_reverse_charge?
        rates = {"0": {tax_amount: BigDecimal(0), total: BigDecimal(0)}}
      else
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
      end

      rates.sort{|x, y| y[0] <=> x[0]}.to_h
    end

    # Get all invoices where the sum of all invoice lines is more than or equal to 0 (which is a SalesInvoice)
    def sales_invoices
      invoices.joins(:invoice_lines)
        .having("SUM(spina_shop_invoice_lines.quantity * spina_shop_invoice_lines.unit_price - spina_shop_invoice_lines.discount) >= 0")
        .group("spina_shop_invoices.id")
    end

    # "The" SalesInvoice (singular) is just the first of potentially multiple sales invoices
    def sales_invoice
      sales_invoices.order(:date, :id).first
    end

    # Get all invoices where the sum of all invoice lines is less than 0 (which is a CreditInvoice)
    def credit_invoices
      invoices.joins(:invoice_lines)
        .having("SUM(spina_shop_invoice_lines.quantity * spina_shop_invoice_lines.unit_price - spina_shop_invoice_lines.discount) < 0")
        .group("spina_shop_invoices.id")
    end

    # "The" CreditInvoice (singular) is just the first of potentially multiple credit invoices
    def credit_invoice
      credit_invoices.order(:date, :id).first
    end

  end
end