module Spina::Shop
  module Admin
    class InvoicesController < AdminController

      before_action :set_breadcrumbs

      def index
        @search_path = spina.shop_admin_invoices_path
        @q = Invoice.order(date: :desc, number: :desc).includes(:order).ransack(params[:q])
        @invoices = @q.result(distinct: true).page(params[:page]).per(25)
      end

      def unpaid
        @search_path = spina.unpaid_shop_admin_invoices_path
        @q = Invoice.order(date: :desc, number: :desc).where(paid: false).includes(:order).ransack(params[:q])
        @invoices = @q.result(distinct: true).page(params[:page]).per(25)
        render :index
      end

      def credit
        @search_path = spina.credit_shop_admin_invoices_path
        @q = Invoice.order(date: :desc, number: :desc).joins(:invoice_lines).group("spina_shop_invoices.id").having("SUM(quantity * unit_price - discount) < 0").ransack(params[:q])
        @invoices = @q.result(distinct: true).page(params[:page]).per(25)
        render :index
      end

      def not_exported
        @search_path = spina.not_exported_shop_admin_invoices_path
        @q = Invoice.order(date: :desc, number: :desc).where(exported: false).includes(:order).ransack(params[:q])
        @invoices = @q.result(distinct: true).page(params[:page]).per(25)
        render :index
      end

      def mark_as_paid
        @invoice = Invoice.find(params[:id])
        @invoice.update(paid: true)
        redirect_back fallback_location: spina.shop_admin_order_path(@invoice.order)
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