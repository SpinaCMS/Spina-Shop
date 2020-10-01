require 'prawn/measurement_extensions'

module Spina::Shop
  class ProductLabelsPdf < Prawn::Document

    def initialize(product_labels, format: "standard")
      super(format_params(format))
      @product_labels = product_labels

      render_labels
    end

    def render_labels
      @product_labels.each.with_index do |product_label, index|
        start_new_page unless index.zero?

        move_down 5.mm
        font_size 5.mm

        if product_label["tht"].present?
          text("THT: #{product_label["tht"]}", align: :center)
        else
          move_down 5.mm
        end
        font_size 32.mm
        text product_label["location"], align: :center
        font_size 10.mm
        text product_label["name"].truncate(85, separator: "..."), align: :center
      end
    end

    private

      def format_params(format)
        case format
        when "square"
          {page_size: [25.mm, 25.mm], margin: 1.mm, print_scaling: :none}
        when "standard"
          {page_size: [150.mm, 102.mm], margin: 5.mm, print_scaling: :none}
        end
      end

  end
end