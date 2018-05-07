module Spina::Shop
  module Admin
    module Stock
      class StockForecastsController < AdminController
        layout 'spina/shop/admin/stock'

        def show
          add_breadcrumb "Voorraad"

          @q = Product.stock_forecast.includes(:translations).where('adjustment <= 0').order("#{params[:order]} #{params[:direction]}").ransack(params[:q])

          @products = @q.result.page(params[:page]).per(50)
        end

      end
    end
  end
end