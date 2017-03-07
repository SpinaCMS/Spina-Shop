require 'prawn/measurement_extensions'

module Spina
  class ReceiptPdf < Prawn::Document
    def initialize(presenter)
      super(page_size: [70.mm, 2000.mm], margin: 0.mm, print_scaling: :none)
      @presenter = presenter

      # Base font size
      font_families.update(
        "Proxima Nova" => {
          normal: "#{Rails.root}/app/assets/fonts/proximanova-regular-webfont.ttf",
          semibold: "#{Rails.root}/app/assets/fonts/proximanova-semibold-webfont.ttf",
          bold: "#{Rails.root}/app/assets/fonts/proximanova-bold-webfont.ttf",
          italic: "#{Rails.root}/app/assets/fonts/proximanova-regitalic-webfont.ttf"
        },
        "Icons" => {
          normal: "#{Rails.root}/app/assets/fonts/plango-next.ttf"
        }
      )
      font "Proxima Nova"
      font_size 8
      default_leading 3

      details()

      move_down 2.cm

      text "*** Thx man ***", align: :center
    end

    def details
      lines = [["", "Omschrijving", "Prijs"]]

      @presenter.invoice.invoice_lines.each do |line|
        lines << ["#{line.quantity}", line.description, @presenter.number_to_currency(line.total)]
      end

      lines << [{content: "Totaal", colspan: 2, font_style: :bold, border_width: 0}, {content: @presenter.total, border_width: 0}]

      table lines, header: true, width: bounds.width, column_widths: {0 => 1.cm, 2 => 1.75.cm}, cell_style: {borders: [:top], border_color: "DDDDDD", padding: [8, 4]} do |t|
        t.before_rendering_page do |page|
          page.row(0).border_top_width = 0
          page.row(0).font_style = :bold
          page.row(1).border_top_width = 2
          page.column(0).align = :right
          page.column(2).align = :right
        end
      end
    end

  end
end