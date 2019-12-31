module Spina::Shop
  class CreditInvoiceGenerator

    # Domain specific exception
    class InvoiceAlreadyCreditedError < StandardError
      def message
        "Credit invoices cannot be credited"
      end
    end

    def initialize(invoice)
      @invoice = invoice
    end

    def generate!(refund_lines = [])
      raise InvoiceAlreadyCreditedError if @invoice.credit?

      # Generate a new unique number for the sequence
      number = InvoiceNumberGenerator.generate!(@invoice.order)

      @credit_invoice = Invoice.new(copyable_attributes_from_invoice)
      @credit_invoice.transaction do
        # Set attributes
        @credit_invoice.number = number
        @credit_invoice.invoice_number = "#{number}"
        @credit_invoice.date = Date.today
        @credit_invoice.paid = false

        if refund_lines.present?
          refund_lines.each do |id, params|
            next unless params["refund"]
            order_item = @invoice.order.order_items.find(id)
            quantity = params["quantity"].to_i

            credit_line = InvoiceLine.new(
              quantity: quantity * -1,
              description: order_item.description,
              unit_price: order_item.unit_price,
              tax_rate: @invoice.vat_reverse_charge? ? BigDecimal(0) : order_item.tax_rate,
              metadata: order_item.metadata
            )

            if params["unit_price"].present?
              credit_line.unit_price = BigDecimal(params["unit_price"].gsub(",", "."))
            elsif order_item.discount_amount != 0
              credit_line.unit_price = order_item.total / order_item.quantity * quantity
              credit_line.description = "#{quantity} x #{credit_line.description}" unless quantity == 1
              credit_line.quantity = -1
            end

            @credit_invoice.invoice_lines << credit_line
          end
        else
          # Copy all lines
          @invoice.invoice_lines.each do |line|
            credit_line = line.dup
            # Recalculate unit price if there was a discount
            if credit_line.discount != 0
              credit_line.discount = 0
              credit_line.unit_price = line.total / line.quantity
              credit_line.quantity = -1
              credit_line.unit_price = line.total
              credit_line.description = "#{line.quantity} x #{credit_line.description}"
            else
              credit_line.quantity = credit_line.quantity * -1
            end
            @credit_invoice.invoice_lines << credit_line
          end
        end

        @credit_invoice.save!
      end
    end

    private

      def copyable_attributes_from_invoice
        copyable_attributes.map do |attribute|
          {attribute => @invoice.send(attribute)}
        end.reduce({}, :merge)
      end

      def copyable_attributes
        %w(customer_id vat_id company_name prices_include_tax vat_reverse_charge country_id country_name order_id order_number customer_number customer_name address_1 postal_code city reference identity_name identity_details)
      end

  end
end