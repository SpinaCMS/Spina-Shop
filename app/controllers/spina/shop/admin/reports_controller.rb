module Spina::Shop
  module Admin
    class ReportsController < AdminController
      before_action :set_breadcrumbs

      def index
      end

      def create
        invoice_ids = Invoice.where(date: params[:start_date]..params[:end_date]).ids
        InvoiceReportJob.perform_later(invoice_ids, params[:email])

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
