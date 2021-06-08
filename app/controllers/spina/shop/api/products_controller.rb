module Spina::Shop
  module Api
    class ProductsController < ApiController
      
      def show
        @product = Product.active.purchasable.find(params[:id])
      end
      
      def index
        products = Product.active.purchasable
        
        # Search for EAN or Location
        exact_match = products.where(ean: params[:q]).or(products.where(location: params[:q])).limit(20)
        
        # Fuzzy search for name
        search = products.search_name(params[:q]).limit(20)
        
        @products = exact_match + search
      end
      
    end
  end
end