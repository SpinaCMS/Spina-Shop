require 'prawn/measurement_extensions'

module Spina::Shop
  class ProductLabelsPdf < Prawn::Document

    def initialize(product_labels, format: "standard")
      super(format_params(format))
      @product_labels = product_labels
      
      # Base font size
      font_families.update(
        "Metropolis" => {
          normal: "#{Spina::Shop.root}/app/assets/fonts/Metropolis-Regular.ttf",
          semibold: "#{Spina::Shop.root}/app/assets/fonts/Metropolis-SemiBold.ttf",
          bold: "#{Spina::Shop.root}/app/assets/fonts/Metropolis-Bold.ttf",
          italic: "#{Spina::Shop.root}/app/assets/fonts/Metropolis-RegularItalic.ttf"
        }
      )
      font "Metropolis"

      render_labels
    end

    def render_labels
      @product_labels.each.with_index do |product_label, index|
        start_new_page unless index.zero?

        move_down 5.mm
        font_size 5.mm

        if product_label["tht"].present?
          text("THT: #{product_label["tht"]}", align: :center, style: :bold)
        else
          move_down 5.mm
        end
        font_size 32.mm
        
        location_regex = product_label["location"].match /(.*-)([A-Z]+-[0-9]+)/
        
        if location_regex && location_regex[1] && location_regex[2]
          font_size 18.mm
          line_width 4
          
          text_box location_regex[1], at: [0, bounds.height - 10.5.mm], height: 24.mm, width: bounds.width / 2, style: :semibold, overflow: :shrink_to_fit, align: :center, valign: :center
          
          bounding_box([bounds.width/2 + 2.mm, bounds.height - 12.mm], height: 24.mm, width: bounds.width / 2 - 2.mm) do
            stroke_bounds
            
            text_box location_regex[2], at: [0, bounds.height + 1.5.mm], height: bounds.height, width: bounds.width, overflow: :shrink_to_fit, style: :semibold, align: :center, valign: :center
            
          end
        else
          text_box product_label["location"], at: [0, bounds.height - 10.mm], height: 32.mm, width: bounds.width, style: :semibold, overflow: :shrink_to_fit, align: :center
        end
        
        font_size 18.mm
        
        text_box product_label["name"], at: [0, bounds.height - 32.mm - 10.mm], align: :center, width: bounds.width, height: bounds.height - 32.mm - 10.mm, overflow: :shrink_to_fit
      end
    end

    private

      def format_params(format)
        case format
        when "square"
          {page_size: [25.mm, 25.mm], margin: 1.mm, print_scaling: :none}
        when "standard"
          {page_size: [150.mm, 102.mm], margin: 10.mm, print_scaling: :none}
        end
      end

  end
end