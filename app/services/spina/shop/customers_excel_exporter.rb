require "caxlsx"

module Spina::Shop
  class CustomersExcelExporter

    def self.export(customer_ids)
      # Group orders by payment method
      customers = Customer.order(:id).where(id: customer_ids)

      # Create new tempfile
      temp_file = Tempfile.new(["customers", ".xlsx"])

      # Generate .xlsx
      Axlsx::Package.new do |doc|
        # New sheet for every payment method
        doc.workbook.add_worksheet(name: "Customers") do |sheet|
          sheet.add_row row_headers

          # Loop through orders
          customers.each do |customer|
            sheet.add_row [customer.id, customer.first_name, customer.last_name, customer.company, customer.email, customer.phone, (I18n.l(customer.date_of_birth, format: :short) if customer.date_of_birth.present?), customer.customer_group.try(:name), (customer.customer_account.present? ? "Yes" : "No"), customer.orders.received.count, customer.number, I18n.l(customer.created_at, format: :long)]
          end
        end

        doc.use_shared_strings = true
        doc.serialize(temp_file.path)
      end

      data = File.open(temp_file.path)
      temp_file.close
      temp_file.unlink
      return data
    end

    private

    def self.row_headers
      %w(ID First\ name Last\ name Company Email Phone Date\ of\ birth Customer\ group Customer\ Account Number\ of\ orders Number Created\ at)
    end
  end
end
