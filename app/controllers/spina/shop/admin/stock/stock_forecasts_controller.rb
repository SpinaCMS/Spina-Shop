module Spina::Shop
  module Admin
    module Stock
      class StockForecastsController < AdminController
        layout 'spina/shop/admin/stock'

        def show
          add_breadcrumb "Voorraad"

          @q = Product.stock_forecast.joins(:translations).where('adjustment <= 0').order("#{params[:order]} #{params[:direction]}").where(spina_shop_product_translations: {locale: I18n.locale}).group("spina_shop_products.id, spina_shop_product_translations.id").ransack(params[:q])

          @products = @q.result.page(params[:page]).per(50)
        end

      end
    end
  end
end