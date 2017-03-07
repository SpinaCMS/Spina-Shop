module Spina
  module Admin
    class InvoicesController < ShopController
      load_and_authorize_resource class: "Spina::Invoice"

      def show
        presenter = InvoicePresenter.new(@invoice, view_context)
        pdf = InvoicePdf.new(presenter)
        send_data pdf.render, filename: "inv_#{@invoice.invoice_number}.pdf", type: "application/pdf"
      end

      def receipt
        presenter = InvoicePresenter.new(@invoice, view_context)
        pdf = ReceiptPdf.new(presenter)
        send_data pdf.render, filename: "receipt_#{@invoice.invoice_number}.pdf", type: "application/pdf"
      end
    end
  end
end