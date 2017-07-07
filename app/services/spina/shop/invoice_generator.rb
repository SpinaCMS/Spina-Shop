module Spina::Shop
  class InvoiceGenerator
    def initialize(order)
      @order = order
      @account = Spina::Account.first
    end

    def generate!
      @customer = @order.customer

      number = InvoiceNumberGenerator.generate!

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
        invoice_number: "#{number}",
        date: Date.today,
        identity_name: @account.name,
        identity_details: "#{@account.address}
        #{@account.postal_code}, #{@account.city}
        #{@account.country}

        #{@account.phone}
        #{@account.email}"
      )

      @order.order_items.each do |order_item|
        invoice.invoice_lines << InvoiceLine.new(
          quantity: order_item.quantity,
          description: order_item.description,
          unit_price: order_item.unit_price,
          tax_rate: order_item.tax_rate,
          metadata: order_item.metadata
        )
        
        if order_item.discount_amount > 0
          invoice.invoice_lines << InvoiceLine.new(
            quantity: -1,
            description: "Korting #{order_item.description}",
            unit_price: order_item.discount_amount,
            tax_rate: order_item.tax_rate,
            metadata: order_item.metadata
          )
        end
      end

      if @order.delivery_option.present?
        invoice.invoice_lines << InvoiceLine.new(
          quantity: 1,
          description: "Verzendkosten",
          unit_price: @order.delivery_price,
          tax_rate: @order.delivery_tax_rate,
          metadata: @order.delivery_metadata
        )
      end

      return invoice if invoice.save!
    end
  end
end