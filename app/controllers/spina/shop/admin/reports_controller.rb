module Spina::Shop
  module Admin
    class ReportsController < AdminController
      before_action :set_breadcrumbs

      def index
      end

      def create
        start_date = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])
        case params[:report_type]
        when "invoices"
          invoice_ids = Invoice.where(date: start_date..end_date).ids
          InvoiceReportJob.perform_later(invoice_ids, params[:email])
        when "payments"
          order_ids = Order.paid.where(paid_at: start_date..end_date).ids
          PaymentsReportJob.perform_later(order_ids, params[:email])
        when "customers"
          customer_ids = Customer.where(created_at: start_date..end_date).ids
          CustomersReportJob.perform_later(customer_ids, params[:email])
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
