require "simple_xlsx"

module Spina::Shop
  class CustomersExcelExporter

    def self.export(customer_ids)
      # Group orders by payment method
      customers = Customer.order(:id).where(id: customer_ids)

      # Create new tempfile
      temp_file = Tempfile.new(["customers", ".xlsx"])
      Zip::OutputStream.open(temp_file) { |zos| }

      # Generate .xlsx
      SimpleXlsx::Serializer.new(temp_file.path) do |doc|
        # New sheet for every payment method
        doc.add_sheet("Customers") do |sheet|
          sheet.add_row row_headers

          # Loop through orders
          customers.each do |customer|
            sheet.add_row [customer.id, customer.first_name, customer.last_name, customer.company, customer.email, customer.phone, (I18n.l(customer.date_of_birth, format: :short) if customer.date_of_birth.present?), customer.customer_group.try(:name), (customer.customer_account.present? ? "Yes" : "No"), customer.orders.received.count, customer.number, I18n.l(customer.created_at, format: :long)]
          end
        end
      end
 
      temp_file
    end

    private

      def self.row_headers
        %w(ID First\ name Last\ name Company Email Phone Date\ of\ birth Customer\ group Customer\ Account Number\ of\ orders Number Created\ at)
      end

  end
end
