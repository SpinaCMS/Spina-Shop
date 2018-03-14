module Spina::Shop
  module Admin
    module Products
      class StockForecastsController < AdminController

        def show
          add_breadcrumb "Producten"

          @products = Product.select('current_date + (floor((stock_level - 4) / trend) :: integer) as restock_date, (ceil(trend * 30) :: integer) as coming_30_days, SUM(CASE WHEN "spina_shop_stock_level_adjustments"."created_at" > current_date - interval \'30 days\' THEN "adjustment" ELSE 0 END) * -1 as past_30_days, SUM(CASE WHEN "spina_shop_stock_level_adjustments"."created_at" > current_date - interval \'90 days\' THEN "adjustment" ELSE 0 END) * -1 as past_90_days, SUM(CASE WHEN "spina_shop_stock_level_adjustments"."created_at" > current_date - interval \'42 days\' THEN "adjustment" ELSE 0 END) * -1 as optimal_stock, stock_level - (SUM(CASE WHEN "spina_shop_stock_level_adjustments"."created_at" > current_date - interval \'42 days\' THEN "adjustment" ELSE 0 END) * -1) as to_order, spina_shop_products.*').where('trend > ?', 0).active.where(stock_enabled: true, archived: false).joins(stock_level_adjustments: :order_item).includes(:product_images, :translations).where('adjustment < 0').where('sales_count > ?', 5).group('"spina_shop_products"."id"').order("#{params[:order] || 'restock_date'} #{params[:direction]}")

          @products = @products.page(params[:page]).per(50)
        end

      end
    end
  end
end