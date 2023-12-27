module Spina::Shop
  module Admin
    class ProductReturnsController < AdminController
      
      def index
        @product_returns = ProductReturn.joins(:order, :product_return_items).order(created_at: :desc).page(params[:page]).per(25)
        add_breadcrumb "Retouren"
      end
      
      def show
        @product_return = ProductReturn.find(params[:id])
      end
      
    end
  end
end