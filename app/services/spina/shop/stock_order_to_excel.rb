require "simple_xlsx"

module Spina::Shop
  class StockOrderToExcel

    def initialize(stock_order)
      @stock_order = stock_order
    end

    def to_excel
      # Create new tempfile
      temp_file = Tempfile.new(["order", ".xlsx"])

      # Generate .xlsx
      SimpleXlsx::Serializer.new(temp_file.path) do |doc|
        doc.add_sheet('order') do |sheet|
          sheet.add_row row_headers

          @stock_order.ordered_stock.each do |ordered|
            sheet.add_row [ordered.quantity, ordered.product.full_name, ordered.product.sku, ordered.product.location, ordered.product.supplier&.name, ordered.product.supplier_reference]
          end
        end
      end

      data = File.read(temp_file.path)
      temp_file.close
      temp_file.unlink
      return data
    end

    private

      def row_headers
        [OrderedStock.human_attribute_name(:quantity), Product.model_name.human, Product.human_attribute_name(:sku), Product.human_attribute_name(:location), Product.human_attribute_name(:supplier), Product.human_attribute_name(:supplier_reference)]
      end

  end
end