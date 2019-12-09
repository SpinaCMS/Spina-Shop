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

    def generate!
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

        # Copy lines
        @invoice.invoice_lines.each do |line|
          credit_line = line.dup
          credit_line.unit_price = credit_line.unit_price * -1
          @credit_invoice.invoice_lines << credit_line
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