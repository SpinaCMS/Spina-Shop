require 'prawn/measurement_extensions'

module Spina::Shop
  class StockOrderPdf < Prawn::Document
    def initialize(stock_order)
      super(page_size: "A4", margin: 15.mm, print_scaling: :none)

      @stock_order = stock_order
      
      # Base font size
      font_families.update(
        "Montserrat" => {
          normal: "#{Spina::Shop.root}/app/assets/fonts/montserrat-regular.ttf",
          semibold: "#{Spina::Shop.root}/app/assets/fonts/montserrat-semibold.ttf",
          bold: "#{Spina::Shop.root}/app/assets/fonts/montserrat-bold.ttf",
          italic: "#{Spina::Shop.root}/app/assets/fonts/montserrat-italic.ttf"
        }
      )
      font "Montserrat"
      font_size 9
      default_leading 3

      header()
      products()
    end

    def header
      font_size 20
      text "#{Spina::Shop::StockOrder.model_name.human} ##{@stock_order.id}"
      font_size 9
    end

    def products
      @stock_order.ordered_stock.joins(:product).order('spina_shop_products.location').each do |ordered|

        stroke_color "dddddd"
        stroke do
          move_down 2.mm
          horizontal_rule
          move_down 2.mm
        end

        font("Montserrat", style: :semibold, size: 12) do
          text ordered.product.location.presence || "Geen locatie"
        end

        font_size(12) do
          text ordered.product.name
          text ordered.product.variant_name
        end
      end
    end

  end
end