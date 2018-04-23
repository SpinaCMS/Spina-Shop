module Spina::Shop
  class PaymentsReportJob < ApplicationJob
    include Rails.application.routes.url_helpers

    def perform(order_ids, email)
      # Generate password
      password = rand(36**6).to_s(36)

      # Create zipfile
      excel_file = PaymentsExcelExporter.export(order_ids, password)

      blob = ActiveStorage::Blob.create_after_upload!(
        io: excel_file,
        filename: "exact_export.xlsx"
        # content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
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