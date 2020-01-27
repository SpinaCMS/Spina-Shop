module Spina::Shop
  module Admin
    module Analytics
      class StockLevelAdjustmentsController < AdminController
        layout 'spina/shop/admin/analytics'

        before_action :set_breadcrumbs

        def show
          @stock_level_adjustments = StockLevelAdjustment.where(category: params[:category]).where("EXTRACT(WEEK FROM
created_at)::int = ?", params[:id]).order(:created_at)
        end

        def index
          params[:start_date] ||= l(Date.today.beginning_of_month.beginning_of_week, format: "%d-%m-%Y")
          params[:end_date] ||= l(Date.today.end_of_month.end_of_week, format: "%d-%m-%Y")

          @start_date = Date.parse(params[:start_date])
          @end_date = Date.parse(params[:end_date])

          @stock_level_adjustments = StockLevelAdjustment.where.not(category: nil).where("created_at::date >= ? AND created_at::date <= ?", @start_date, @end_date).select("EXTRACT(WEEK FROM
created_at)::int as weekly, category, SUM(adjustment) as total").group("weekly, category")
        end

        private

          def set_breadcrumbs
            add_breadcrumb t("spina.shop.analytics.title")
          end

      end
    end
  end
end