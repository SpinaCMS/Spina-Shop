module Spina::Shop
  module StockManagement
    class SearchController < StockManagementController

      def index
      end

      def show
        @products = Spina::Shop::Product.where.not(location: nil).search(params[:q])
      end

    end
  end
end