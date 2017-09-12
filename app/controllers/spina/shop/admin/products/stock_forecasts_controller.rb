module Spina::Shop
  module Admin
    module Products
      class StockForecastsController < AdminController

        def show
          add_breadcrumb "Producten"
          @products = Product.select('current_date + (floor((stock_level - 4) / trend) :: integer) as restock_date, *').active.where(stock_enabled: true, archived: false).includes(:product_images).where('sales_count > ?', 5).order('restock_date')
          @products = @products.page(params[:page]).per(250)
        end

      end
    end
  end
end