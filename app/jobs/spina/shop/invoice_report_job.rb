module Spina::Shop
  class InvoiceReportJob < ApplicationJob

    def perform(invoice_ids, email)
      # Generate password
      password = rand(36**6).to_s(36)

      # Create zipfile
      zipfile = InvoicesPdfsExporter.export(invoice_ids, password)

      # Upload zipfile
      uploader = ExportsUploader.new
      uploader.store!(zipfile)

      # Send URL in email
      ExportMailer.exported(uploader.url, email).deliver_later
    end

    private


  end
end