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

      private

        def set_breadcrumbs
          add_breadcrumb Spina::Shop::Invoice.model_name.human(count: 2), spina.shop_admin_invoices_path
        end

    end
  end
end