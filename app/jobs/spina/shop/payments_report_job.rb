module Spina::Shop
  class PaymentsReportJob < ReportJob

    def perform(order_ids, email)
      # Generate password
      password = rand(36**6).to_s(36)

      # Create zipfile
      excel_file = PaymentsExcelExporter.export(order_ids, password)

      blob = ActiveStorage::Blob.create_after_upload!(
        io: excel_file,
        filename: "payments.xlsx",
        content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )

      excel_file.close

      # Send URL in email
      ExportMailer.exported(url_for(blob), email).deliver_later
    end

  end
end