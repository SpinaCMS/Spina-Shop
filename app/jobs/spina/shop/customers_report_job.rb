module Spina::Shop
  class CustomersReportJob < ReportJob

    def perform(customer_ids, email)
      # Create zipfile
      excel_file = CustomersExcelExporter.export(customer_ids)

      blob = ActiveStorage::Blob.create_after_upload!(
        io: excel_file,
        filename: "customers.xlsx",
        content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )

      excel_file.close

      # Send URL in email
      ExportMailer.exported(url_for(blob), email).deliver_later
    end

  end
end