module Spina::Shop
  module Admin
    module Products
      class StockForecastsController < AdminController

        def show
          add_breadcrumb "Producten"
          @products = Product.select('current_date + (floor((stock_level - 4) / trend) :: integer) as restock_date, (ceil(trend * 30) :: integer) as coming_30_days, *').where('trend > ?', 0).active.where(stock_enabled: true, archived: false).includes(:product_images, :translations).where('sales_count > ?', 5).order("#{params[:order] || 'restock_date'} #{params[:direction]}")
          @products = @products.page(params[:page]).per(20)
        end

      end
    end
  end
end