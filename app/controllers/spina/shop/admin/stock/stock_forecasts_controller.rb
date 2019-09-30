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
        end

      end
    end
  end
end