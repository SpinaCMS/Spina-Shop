require 'zip'

module Spina::Shop
  class InvoicesPdfsExporter

    def self.export(invoice_ids, password)
      invoices = Invoice.where(id: invoice_ids)

      zipfile = Tempfile.new(['', '.zip'])
      Zip::OutputStream.open(zipfile.path) do |zipstream|
        invoices.find_each do |invoice|
          zipstream.put_next_entry(invoice.filename)
          presenter = InvoicePresenter.new(invoice, ActionView::Base.new)
          zipstream.write InvoicePdf.new(presenter).render
        end
      end
      zipfile.close
      zipfile
    end

  end
end
