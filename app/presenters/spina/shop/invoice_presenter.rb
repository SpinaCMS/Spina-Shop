module Spina::Shop
  class InvoicePresenter
    attr_accessor :invoice, :view_context

    delegate :customer_name, :company_name, :address_1, :postal_code, :city, :number, :customer_number, :date, :identity_name, :invoice_number, :identity_details, :country_name, :vat_id, :reference, to: :invoice
    delegate :number_to_currency, :number_with_precision, to: :view_context

    def initialize(invoice, view_context)
      @invoice = invoice
      @view_context = view_context
    end

    def sub_total
      view_context.number_to_currency(invoice.sub_total)
    end

    def total
      view_context.number_to_currency(invoice.total)
    end

    def to_be_paid
      view_context.number_to_currency(invoice.order.to_be_paid)
    end

    def gift_card_amount
      invoice.order.gift_card_amount
    end

    def has_discount?
      @has_discount ||= invoice.invoice_lines.where.not(discount: 0).any?
    end

    def paid?
      invoice.order&.paid?
    end

    def order
      invoice.order
    end

    def order_number
      invoice.order.try(:number)
    end

    def payment_method
      invoice.order.try(:payment_method)
    end

  end
end