require 'prawn/measurement_extensions'

module Spina::Shop
  class InvoicePdf < Prawn::Document
    def initialize(presenter, locale: I18n.locale)
      I18n.locale = locale
      super(page_size: "A4", margin: 15.mm, print_scaling: :none)

      @presenter = presenter
      
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

      @logo_path = Rails.root.join('app', 'assets', 'images', 'invoice_logo.jpg').to_s

      recipient()
      header()
      invoice_details()
      footer()
    end

    def recipient
      float do
        indent(12.cm) do
          image @logo_path, fit: [bounds.width, 25.mm], position: :center
          move_down 5.mm

          text @presenter.identity_name, style: :semibold
          text @presenter.identity_details
        end
      end

      move_down 45.mm
      indent(2.cm) do
        if @presenter.company_name.present?
          text @presenter.company_name, style: :semibold
          text @presenter.customer_name
        else
          text @presenter.customer_name, style: :semibold
        end
        text @presenter.address_1
        text [@presenter.postal_code, @presenter.city].join(' ')
        text @presenter.country_name
      end
      move_down 20.mm
    end

    def header
      float do
        indent(12.cm) do
          formatted_text [{text: "#{Invoice.human_attribute_name(:date)}: "}, {text: I18n.l(@presenter.date, format: '%d-%m-%Y'), style: :semibold}]
          formatted_text [{text: "#{Order.human_attribute_name(:payment_method)}: "}, {text: @presenter.payment_method, style: :semibold}]
        end
      end

      text "#{Invoice.model_name.human} #{@presenter.invoice_number}", style: :semibold, size: 24
      text "#{Invoice.human_attribute_name(:customer_number)}: #{@presenter.customer_number}"
      text "#{Order.human_attribute_name(:order_number)}: #{@presenter.order_number}"

      if @presenter.reference.present?
        text "#{Invoice.human_attribute_name(:reference)}: #{@presenter.reference}"        
      end

      if @presenter.vat_id.present?
        text "#{Customer.human_attribute_name(:vat_id)}: #{@presenter.vat_id}"
      end

      move_down 5.mm
    end

    def invoice_details()
      lines = []
      headers = ["", InvoiceLine.human_attribute_name(:description), InvoiceLine.human_attribute_name(:price), InvoiceLine.human_attribute_name(:total), InvoiceLine.human_attribute_name(:tax)]
      headers.insert(3, InvoiceLine.human_attribute_name(:discount)) if @presenter.has_discount?

      lines << headers

      @presenter.invoice.invoice_lines.each do |line|
        invoice_line = ["#{line.quantity} x", 
          line.description, 
          @presenter.number_to_currency(line.unit_price), 
          @presenter.number_to_currency(line.total), 
          ("#{@presenter.number_with_precision(line.tax_rate, precision: 0)}%" if line.tax_rate > 0)]
        invoice_line.insert(3, "– #{@presenter.number_to_currency(line.discount)}") if @presenter.has_discount?
        lines << invoice_line
      end

      colspan = @presenter.has_discount? ? 4 : 3

      lines << [{content: Invoice.human_attribute_name(:sub_total), colspan: colspan, font_style: :semibold, border_width: 2}, {content: @presenter.sub_total, border_width: 2}, {content: "", border_width: 2}]

      @presenter.invoice.tax_amount_by_rates.each do |rate|
        unless rate[0] == 0
          lines << [{content: I18n.t('spina.shop.tax.rate', rate: @presenter.number_with_precision(rate[0], precision: 0)), colspan: colspan, border_width: 0}, {content: @presenter.number_to_currency(rate[1][:tax_amount]), border_width: 0}, {content: "", border_width: 0}]
        end
        if @presenter.invoice.vat_reverse_charge 
          lines << [{content: I18n.t('spina.shop.tax.vat_reverse_charge'), colspan: colspan, border_width: 0}, {content: @presenter.number_to_currency(BigDecimal.new(0)), border_width: 0}, {content: "", border_width: 0}]
        end
      end

      lines << [{content: Invoice.human_attribute_name(:total), colspan: colspan, font_style: :semibold, border_width: 0}, {content: @presenter.total, border_width: 0}, {content: "", border_width: 0}]

      if @presenter.gift_card_amount > 0
        lines << [{content: GiftCard.model_name.human, colspan: colspan, font_style: :semibold, border_width: 0}, {content: "– #{@presenter.view_context.number_to_currency(@presenter.gift_card_amount)}", border_width: 0}, {content: "", border_width: 0}]
      
        lines << [{content: Order.human_attribute_name(:to_be_paid), colspan: colspan, font_style: :semibold, border_width: 0}, {content: @presenter.to_be_paid, border_width: 0, font_style: :semibold}, {content: "", border_width: 0}]
      end

      table lines, header: true, column_widths: {0 => 2.cm, 1 => 8.cm, 4 => 2.cm}, width: bounds.width, cell_style: {borders: [:top], border_color: "DDDDDD", padding: 8} do |t|
        t.before_rendering_page do |page|
          page.row(0).border_top_width = 0
          page.row(0).font_style = :semibold
          page.row(1).border_top_width = 2
          page.column(0).align = :right
          page.column(2).align = :right
          page.column(3).align = :right
          page.column(4).align = :right
        end
      end
    end

    def footer
      # Footer
    end
  end
end