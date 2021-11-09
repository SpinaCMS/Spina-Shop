module Spina::Shop
  module Admin
    module Analytics
      class OrdersController < AdminController
        layout "spina/shop/admin/analytics"

        before_action :set_breadcrumbs

        def index
          params[:from] ||= l(Date.today, format: "%d-%m-%Y")
          params[:to] ||= l(Date.today, format: "%d-%m-%Y")
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

          case params[:online_offline]
          when "online"
            orders = Spina::Shop::Order.where(pos: false)
          when "offline"
            orders = Spina::Shop::Order.where(pos: true)
          else
            orders = Spina::Shop::Order.all
          end

          orders = orders.where(store_id: params[:store_ids]) if params[:store_ids].present?
          
          orders = orders.where(billing_country_id: params[:billing_country_id]) if params[:billing_country_id].present?

          @orders = orders.where(paid_at: @from..@to).joins(:order_items).group("date_trunc('#{@period}', spina_shop_orders.paid_at)").where("spina_shop_order_items.metadata->>'sales_category_code' != '2010'").sum('CASE WHEN prices_include_tax THEN round(quantity * (unit_price / ((100 + tax_rate) / 100)), 2) - round(discount_amount / ((100 + tax_rate) / 100), 2) ELSE quantity * unit_price - discount_amount END').sort_by(&:first)

          @gift_cards_sold = orders.where(paid_at: @from..@to).joins(:order_items).group("date_trunc('#{@period}', spina_shop_orders.paid_at)").sum("CASE WHEN spina_shop_order_items.metadata->>'sales_category_code' = '2010' THEN CASE WHEN prices_include_tax THEN round(quantity * (unit_price / ((100 + tax_rate) / 100)), 2) - round(discount_amount / ((100 + tax_rate) / 100), 2) ELSE quantity * unit_price - discount_amount END ELSE 0 END").sort_by(&:first).map(&:last)

          @gift_cards = orders.where(paid_at: @from..@to).group("date_trunc('#{@period}', spina_shop_orders.paid_at)").sum('gift_card_amount').to_a.sort_by(&:first).map(&:last)

          @counts = orders.where(paid_at: @from..@to).group("date_trunc('#{@period}', spina_shop_orders.paid_at)").count.sort_by(&:first).map(&:last)

          @discounts = orders.where(paid_at: @from..@to).joins(:order_items).group("date_trunc('#{@period}', spina_shop_orders.paid_at)").sum("CASE WHEN prices_include_tax THEN round(discount_amount / ((100 + tax_rate) / 100), 2) ELSE discount_amount END").sort_by(&:first).map(&:last)

          @cost_prices = orders.where(paid_at: @from..@to).joins(:order_items).group("date_trunc('#{@period}', spina_shop_orders.paid_at)").sum('-1 * unit_cost_price * quantity').sort_by(&:first)

          @profit = @orders.map.with_index do |invoice, index|
            invoice.last - -1 * @cost_prices[index].last
          end.to_json

          @labels_json = @orders.map do |date, total|
            if @period == "year"
              l(date, format: "%Y")
            elsif @period == "month"
              l(date, format: "%B %Y")
            else
              l(date, format: "%d %B %Y")
            end
          end.to_json

          @data_json = @orders.map(&:last).to_json
          @cost_json = @cost_prices.map(&:last).to_json
        end

        private

          def set_breadcrumbs
            add_breadcrumb t('spina.shop.analytics.title')
          end

      end
    end
  end
end