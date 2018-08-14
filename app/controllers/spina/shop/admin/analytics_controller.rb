module Spina::Shop
  module Admin
    class AnalyticsController < AdminController
      layout 'spina/shop/admin/reports'

      before_action :set_breadcrumbs

      def show
      end

      def create
        @from = Date.parse(params[:from])
        @to = Date.parse(params[:to])
        @period = case params[:period]
        when "year"
          "year"
        when "month"
          "month"
        else
          "day"
        end

        @invoices = Spina::Shop::Invoice.where(created_at: @from..@to).joins(:invoice_lines).group("date_trunc('#{@period}', spina_shop_invoices.created_at)").sum('CASE WHEN prices_include_tax THEN round(quantity * (unit_price / ((100 + tax_rate) / 100)), 2) ELSE quantity * unit_price END').sort_by(&:first)

        @cost_prices = Spina::Shop::Order.where(paid_at: @from..@to).joins(:order_items).group("date_trunc('#{@period}', spina_shop_orders.paid_at)").sum('-1 * unit_cost_price * quantity').sort_by(&:first)

        @profit = @invoices.map.with_index do |invoice, index|
          invoice.last - -1 * @cost_prices[index].last
        end.to_json

        @labels_json = @invoices.map do |date, total|
          if @period == "year"
            l(date, format: "%Y")
          elsif @period == "month"
            l(date, format: "%B %Y")
          else
            l(date, format: "%d %B %Y")
          end
        end.to_json

        @data_json = @invoices.map(&:last).to_json
        @cost_json = @cost_prices.map(&:last).to_json
      end

      private

        def set_breadcrumbs
          add_breadcrumb t('spina.shop.reports.title'), spina.shop_admin_reports_path
          add_breadcrumb t('spina.shop.analytics.title')
        end

    end
  end
end