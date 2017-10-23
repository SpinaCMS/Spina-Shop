module Spina::Shop
  class PaymentsReportJob < ApplicationJob

    def perform(order_ids, email)
      # Generate password
      password = rand(36**6).to_s(36)

      # Create zipfile
      excel_file = PaymentsExcelExporter.export(order_ids, password)

      # Upload zipfile
      uploader = ExportsUploader.new
      uploader.store!(excel_file)

      # Send URL in email
      ExportMailer.exported(uploader.url, email).deliver_later
    end

    private


  end
end