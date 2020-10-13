module Spina::Shop
  module Admin
    module Stock
      class StockForecastsController < AdminController
        layout 'spina/shop/admin/stock'

        def show
          add_breadcrumb "Voorraad"

          @unique_locations ||= Spina::Shop::Product.active.where.not(location: "").pluck('location').uniq.compact.sort
          @locations = @unique_locations.map do |location|
            regex = location.match(/\A(\d*)([a-zA-Z]*).*\z/)
            regex.try(:[], 1).presence || regex.try(:[], 2).presence
          end.uniq.compact.sort_by do |location|
            location.length > 2 ? '1' : '0' + location
          end

          @q = Product.stock_forecast.joins(:translations).order("#{params[:order]} #{params[:direction]}").where(spina_shop_product_translations: {locale: I18n.locale}).group("spina_shop_products.id, spina_shop_product_translations.id").ransack(params[:q])
          @products = @q.result.page(params[:page]).per(50)

          respond_to do |format|
            format.js
            format.html
            format.csv do
              data = CSV.generate do |csv|
                csv << %w(ID Product Locatie Lopen30 Lopen90 Lopen365 Verkoop30 Verkoop90 Verkoop365 Voorraad Optimale\ voorraad Voorraadverschil Doorlooptijd Herinneren Verkoopprijs Kostprijs Voorraadwaarde)
                @products = @q.result.page(params[:page]).per(5000)
                @products.each.each do |product|
                  csv << [product.id, 
                    product.full_name, 
                    product.location, 
                    product.order_picking_30_days, 
                    product.order_picking_90_days, 
                    product.order_picking_365_days,
                    product.past_30_days,
                    product.past_90_days,
                    product.past_365_days,
                    product.stock_level,
                    product.optimal_stock,
                    product.stock_difference,
                    product.lead_time.round,
                    product.in_stock_reminders_count,
                    view_context.number_to_currency(product.base_price),
                    view_context.number_to_currency(product.cost_price),
                    view_context.number_to_currency(product.stock_value)
                  ]
                end
              end
              
              send_data data, filename: "voorraad.csv", disposition: "attachment"
            end
          end
        end

      end
    end
  end
end