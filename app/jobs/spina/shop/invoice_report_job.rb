module Spina::Shop
  class InvoiceReportJob < ApplicationJob
    include Rails.application.routes.url_helpers

    def perform(invoice_ids, email)
      # Generate password
      password = rand(36**6).to_s(36)

      # Create zipfile
      zipfile = InvoicesPdfsExporter.export(invoice_ids, password)

      # Upload
      blob = ActiveStorage::Blob.create_after_upload!(
        io: zipfile,
        filename: "invoices.zip",
        content_type: "application/zip"
      )

      zipfile.close

      # Send URL in email
      ExportMailer.exported(url_for(blob), email).deliver_later
    end

    protected

      def default_url_options
        Rails.application.config.action_mailer.default_url_options
      end


  end
end