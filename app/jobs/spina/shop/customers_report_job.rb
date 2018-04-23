module Spina::Shop
  class CustomersReportJob < ApplicationJob

    def perform(customer_ids, email)
      # Create zipfile
      excel_file = CustomersExcelExporter.export(customer_ids)

      blob = ActiveStorage::Blob.create_after_upload!(
        io: excel_file,
        filename: "exact_export.zip",
        content_type: "application/zip"
      )

      # Send URL in email
      ExportMailer.exported(url_for(blob), email).deliver_later
    end

    protected

      def default_url_options
        Rails.application.config.action_mailer.default_url_options
      end

  end
end