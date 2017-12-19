module Spina::Shop
  class CustomersReportJob < ApplicationJob

    def perform(customer_ids, email)
      # Create zipfile
      excel_file = CustomersExcelExporter.export(customer_ids)

      # Upload zipfile
      uploader = ExportsUploader.new
      uploader.store!(excel_file)

      # Send URL in email
      ExportMailer.exported(uploader.url, email).deliver_later
    end

    private


  end
end