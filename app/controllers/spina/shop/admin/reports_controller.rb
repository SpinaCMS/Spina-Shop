module Spina::Shop
  module Admin
    class ReportsController < AdminController
      before_action :set_breadcrumbs

      def index
      end

      def create
        case params[:report_type]
        when "invoices"
          invoice_ids = Invoice.where(date: params[:start_date]..params[:end_date]).ids
          InvoiceReportJob.perform_later(invoice_ids, params[:email])
        when "payments"
          order_ids = Order.paid.where(paid_at: params[:start_date]..params[:end_date]).ids
          PaymentsReportJob.perform_later(order_ids, params[:email])
        end

        flash[:success] = t('spina.shop.reports.start_exporting_html')
        redirect_to spina.shop_admin_reports_path
      end

      private

        def set_breadcrumbs
          add_breadcrumb t('spina.shop.reports.title'), spina.shop_admin_reports_path
        end

    end
  end
end
