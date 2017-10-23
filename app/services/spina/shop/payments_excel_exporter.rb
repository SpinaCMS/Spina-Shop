require "simple_xlsx"

module Spina::Shop
  class PaymentsExcelExporter

    def self.export(order_ids, password)
      # Group orders by payment method
      orders = Order.order(:order_number).where(id: order_ids).group_by(&:payment_method)

      # Create new tempfile
      temp_file = Tempfile.new("payments")
      Zip::OutputStream.open(temp_file) { |zos| }

      # Generate .xlsx
      SimpleXlsx::Serializer.new(temp_file.path) do |doc|
        orders.each_key do |key|

          # New sheet for every payment method
          doc.add_sheet(key) do |sheet|
            sheet.add_row row_headers

            # Loop through orders
            orders[key].each do |order|
              sheet.add_row [order.number, order.invoices.pluck(:invoice_number).join(', '), I18n.l(order.paid_at, format: :long), order.billing_name, order.total, order.gift_card_amount, (order.payment_method == "cash" ? order.to_be_paid_round : order.to_be_paid), (order.payment_method == "cash" ? order.to_be_paid_rounding_difference : nil), order.payment_method]
            end
          end
        end
      end
 
      temp_file.close
      temp_file
    end

    private

      def self.row_headers
        %w(Order\ number Invoice\ number Payment\ date Customer Total Giftcard To\ be\ paid Rounding\ difference Payment\ method)
      end

  end
end
