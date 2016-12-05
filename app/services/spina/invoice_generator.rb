module Spina
  class InvoiceGenerator
    def initialize(order)
      @order = order
    end

    def generate!
      @customer = @order.customer

      number = InvoiceNumberGenerator.generate

      invoice = Invoice.new(
        order_id: @order.id,
        customer_id: @customer.id,
        prices_include_tax: @order.prices_include_tax,
        country_id: @order.billing_country.id,
        country_name: @order.billing_country.name,
        order_number: @order.number,
        customer_number: @customer.number,
        customer_name: @customer.full_name,
        address_1: @order.billing_address,
        postal_code: @order.billing_postal_code,
        city: @order.billing_city,
        number: number,
        invoice_number: "MH#{number}",
        date: Date.today,
        identity_name: "Mr. Hop",
        identity_details: "Grotestraat 1
        1234 AB, Venray
        Nederland

        0612345678
        info@mrhop.nl
        www.mrhop.nl"
      )

      @order.order_items.each do |order_item|
        invoice.invoice_lines << InvoiceLine.new(
          quantity: order_item.quantity,
          description: order_item.description,
          unit_price: order_item.unit_price,
          tax_rate: order_item.tax_rate,
          export_data: {
            vat_code: order_item.vat_code,
            sales_category_code: order_item.sales_category_code
          }
        )
      end

      invoice.invoice_lines << InvoiceLine.new(
        quantity: 1,
        description: "Verzendkosten",
        unit_price: @order.delivery_price,
        tax_rate: @order.delivery_tax_rate,
        export_data: {
          vat_code: @order.delivery_option.tax_group.vat_code_for_order(@order),
          sales_category_code: @order.delivery_option.sales_category.code_for_order(@order)
        }
      )

      return invoice if invoice.save!
    end
  end
end