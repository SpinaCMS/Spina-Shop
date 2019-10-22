module Spina::Shop
  module Admin
    class InvoicesController < AdminController

      before_action :set_breadcrumbs

      def index
        @invoices = Invoice.order(date: :desc, number: :desc).page(params[:page]).per(25)
      end

      def unpaid
        @invoices = Invoice.order(date: :desc, number: :desc).joins(:order).where(spina_shop_orders: {paid_at: nil}).page(params[:page]).per(25)
        render :index
      end

      def show
        @invoice = Invoice.find(params[:id])
        presenter = InvoicePresenter.new(@invoice, view_context)
        pdf = InvoicePdf.new(presenter)
        send_data pdf.render, filename: @invoice.filename, type: "application/pdf"
      end

      def credit
        @invoice = Invoice.find(params[:id])
        @credit_invoice = @invoice.dup
        @credit_invoice.order = @invoice.order
        @credit_invoice.customer = @invoice.customer
        @credit_invoice.country = @invoice.country
        @credit_invoice.paid = false
        @credit_invoice.date = Date.today
        @credit_invoice.exported = false
        @credit_invoice.number = InvoiceNumberGenerator.generate!(@invoice.order)

        # Copy invoice lines
        @invoice.invoice_lines.each do |invoice_line|
          credit_invoice_line = invoice_line.dup
          credit_invoice_line.unit_price = credit_invoice_line.unit_price * -1
          @credit_invoice.invoice_lines << credit_invoice_line
        end

        @credit_invoice.save

        redirect_to spina.shop_admin_order_path(@invoice.order)
      end

      private

        def set_breadcrumbs
          add_breadcrumb Spina::Shop::Invoice.model_name.human(count: 2), spina.shop_admin_invoices_path
        end

    end
  end
end