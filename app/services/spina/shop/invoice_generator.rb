module Spina::Shop
  class InvoiceGenerator
    def initialize(order)
      @order = order
      @account = Spina::Account.first
    end

    def generate!
      @customer = @order.customer

      # Generate a new unique number for the sequence
      number = generate_number!

      invoice = Invoice.new(
        order_id: @order.id,
        customer_id: @customer.id,
        vat_id: @customer.vat_id,
        company_name: @customer.company,
        prices_include_tax: @order.prices_include_tax,
        vat_reverse_charge: @order.vat_reverse_charge?,
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
        reference: @order.reference,
        identity_name: identity_name,
        identity_details: identity_details
      )

      @order.order_items.each do |order_item|
        invoice.invoice_lines << InvoiceLine.new(
          quantity: order_item.quantity,
          description: order_item.description,
          unit_price: order_item.unit_price,
          tax_rate: invoice.vat_reverse_charge? ? BigDecimal.new(0) : order_item.tax_rate,
          metadata: order_item.metadata
        )
        
        if order_item.discount_amount > 0
          invoice.invoice_lines << InvoiceLine.new(
            quantity: -1,
            description: "Korting #{order_item.description}",
            unit_price: order_item.discount_amount,
            tax_rate: invoice.vat_reverse_charge? ? BigDecimal.new(0) : order_item.tax_rate,
            metadata: order_item.metadata
          )
        end
      end

      if @order.delivery_option.present?
        invoice.invoice_lines << InvoiceLine.new(
          quantity: 1,
          description: "Verzendkosten",
          unit_price: @order.delivery_price,
          tax_rate: invoice.vat_reverse_charge? ? BigDecimal.new(0) : @order.delivery_tax_rate,
          metadata: @order.delivery_metadata
        )
      end

      return invoice if invoice.save!
    end

    private

      def generate_number!
        InvoiceNumberGenerator.generate!(@order)
      end

      def identity_name
        @account.name
      end

      def identity_details
        "#{@account.address}
        #{@account.postal_code}, #{@account.city}

        #{@account.phone}
        #{@account.email}"
      end
  end
end