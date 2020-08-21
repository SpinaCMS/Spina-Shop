require 'rqrcode'
require 'prawn/measurement_extensions'

module Spina::Shop
  class PackingSlipPdf < Prawn::Document
    def initialize(order)
      super(page_size: "A4", margin: 15.mm, print_scaling: :none)
      @order = order

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
      font_size 10
      default_leading 3

      qrcode()
      header()
      order_title()
      order_details()

      number_pages "<page> / <total>", 
       {:at => [bounds.right - 50, 0],
        :align => :right,
        :size => 14}
    end

    def qrcode
      float do
        qrcode = RQRCode::QRCode.new(@order.to_global_id.to_s)
        svg qrcode.as_svg, width: 3.cm, position: :right
      end
    end

    def header
      text "Pakbon", style: :semibold, size: 28
      fill_color '999999'
      text "#{I18n.l @order.order_prepared_at, format: '%d %B %Y - %H:%M'}"
      fill_color '000000'
      move_down 1.cm
      text @order.delivery_name, style: :semibold
      text @order.delivery_address
      text [@order.delivery_postal_code, @order.delivery_city, @order.delivery_country.try(:code)].join(', ')
      move_down 1.cm
    end

    def order_title
      float do
        t = "#{@order.order_items.products.sum(:quantity)} producten"
        if @order.order_items.product_bundles.sum(:quantity) > 0
          t = t + "/ #{@order.order_items.product_bundles.sum(:quantity)} productbundels"
        end
        text t, size: 12, align: :right
      end
      text "#{Spina::Shop::Order.model_name.human} ##{@order.number}", style: :semibold, size: 18
    end

    def order_details
      lines = [["Aantal", "Omschrijving", "Locatie", "Controle"]]

      # Get all products
      products = @order.order_items.products.includes(:orderable).map do |order_item|
        { location: order_item.orderable.location, quantity: order_item.quantity, description: order_item.description }
      end

      # Get all products in product bundles
      products = products + @order.order_items.product_bundles.includes(:orderable).map do |order_item|
        order_item.orderable.bundled_products.map do |bundled_product|
          { location: bundled_product.product.location, quantity: bundled_product.quantity * order_item.quantity, description: bundled_product.product.name + "\n #{order_item.description}" }
        end
      end.flatten

      products = products + @order.order_items.custom_products.includes(:orderable).map do |order_item|
        {location: nil, quantity: order_item.quantity, description: order_item.description}
      end

      checkbox = make_table([[" "]], width: 1.cm, position: :right, cell_style: {border_width: 1.5, border_color: "cccccc", height: 0.5.cm})

      products.sort_by{|p| (p[:location].present? ? "0" : "1") + p[:location].to_s}.each do |product|
        lines << ["#{product[:quantity]} x", product[:description], product[:location], checkbox]
      end

      table lines, header: true, column_widths: {0 => 2.cm, 1 => 10.cm}, width: bounds.width, cell_style: {borders: [:top], border_color: "DDDDDD", padding: 10} do |t|
        t.before_rendering_page do |page|
          page.row(0).border_top_width = 0
          page.row(0).font_style = :bold
          page.row(1).border_top_width = 2
          page.column(0).align = :right
          page.column(3).align = :right
          page.column(3).padding_right = 0
        end
      end
    end
  end
end