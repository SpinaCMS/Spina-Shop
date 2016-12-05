module Elmas
  SalesEntry.class_eval do
    def mandatory_attributes
      [:journal, :customer, :sales_entry_lines]
    end
  end
end

module Spina
  class ExactOnline

    class << self

      def invoice_to_sales_entry(invoice)
        authorize

        # Dagboek verkoop is 70
        journal = 70

        account = Elmas::Account.new(code: invoice.customer_number.to_s.rjust(18)).find_by(filters: [:code]).records.first
        account_id = account.try(:id)

        unless account
          account = Elmas::Account.new(name: invoice.customer_name, code: invoice.customer_number.to_s, status: "C", country: invoice.country.iso_3166)
          response = account.save
          account_id = response.parsed.result["ID"]
        end

        sales_entry = Elmas::SalesEntry.new(journal: journal, customer: account_id, entry_date: invoice.date, your_ref: invoice.order.number, description: "Bestelling webshop ##{invoice.order.number}")
        sales_entry_lines = []

        invoice.invoice_lines.each do |invoice_line|
          gl_account = Elmas::GLAccount.new(code: invoice_line.export_data["sales_category_code"].to_s).find_by(filters: [:code]).records.first
          vat_code = invoice_line.export_data["vat_code"].to_s

          sales_entry_lines << Elmas::SalesEntryLine.new(amount_FC: invoice_line.total, GL_account: gl_account, VAT_code: vat_code, description: invoice_line.description, cost_center: invoice.country.iso_3166)
        end

        sales_entry.sales_entry_lines = sales_entry_lines
        response = sales_entry.save

        if guid = response.parsed.result["EntryID"]
          invoice.update_attributes(exported: true, export_data: {exact_sales_entry_id: guid})
        end
      end

      private

        def authorize
          unless Elmas.authorized?
            Elmas.configure do |config|
              config.access_token = Elmas.authorize(Rails.application.secrets.exact_username, Rails.application.secrets.exact_password).access_token
            end
          end
        end
    end
  end
end