module Spina::Shop
  module StockManagement
    class LocationsController < StockManagementController

      def index
      end

      def show
        @location = params[:id]
        @products = Product.active.includes(:translations).where("location LIKE ?", "#{params[:id]}%").order(:location)
      end

    end
  end
end