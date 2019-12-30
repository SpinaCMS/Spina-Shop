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

    def generate!(order_item_params = [])
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

        if order_item_params.present?
          order_item_params.keep_if{|o|o["id"].present?}.each do |order_item_param|
            order_item = @invoice.order.order_items.find(order_item_param["id"])
            @credit_invoice.invoice_lines << InvoiceLine.new(
              quantity: order_item_param["quantity"].to_i * -1,
              description: order_item.description,
              unit_price: BigDecimal(order_item_param["unit_price"].gsub(",", ".")),
              tax_rate: @invoice.vat_reverse_charge? ? BigDecimal(0) : order_item.tax_rate,
              metadata: order_item.metadata
            )
          end
        else
          # Copy all lines
          @invoice.invoice_lines.each do |line|
            credit_line = line.dup
            credit_line.quantity = credit_line.quantity * -1
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