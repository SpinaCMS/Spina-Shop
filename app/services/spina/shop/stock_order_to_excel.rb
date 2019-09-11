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

          @stock_order.ordered_stock.sort_by{|o|o.product.full_name}.each do |ordered|
            sheet.add_row [ordered.product.supplier_reference, ordered.quantity, ordered.product.name, ordered.product.variant_name]
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
        [Product.human_attribute_name(:supplier_reference), OrderedStock.human_attribute_name(:quantity), Product.model_name.human, Product.human_attribute_name(:variant_name)]
      end

  end
end