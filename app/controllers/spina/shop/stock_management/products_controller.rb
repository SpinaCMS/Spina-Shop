module Spina::Shop
  module StockManagement
    class ProductsController < StockManagementController

      def search
        @q = params[:q]
        @products = Spina::Shop::Product.active.where.not(location: nil).purchasable.search(@q).limit(25)
      end

    end
  end
end