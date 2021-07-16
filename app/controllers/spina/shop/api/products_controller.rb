module Spina::Shop
  module Api
    class ProductsController < ApiController
      rescue_from ActiveRecord::RecordNotFound, with: :return_404
      
      def show
        @product = Product.active.purchasable.find(params[:id])
      end
      
      def scan
        @product = Product.active.purchasable.where("location = :q OR ean = :q", q: params[:q]).first
        if @product
          render :show
        else
          return_404
        end
      end
      
      def index
        products = Product.active.purchasable
        
        # Search for EAN or Location
        exact_match = products.where(ean: params[:q]).or(products.where(location: params[:q])).limit(20)
        
        # Fuzzy search for name
        search = products.search_name(params[:q]).limit(20)
        
        @products = exact_match + search
      end
      
      private
      
        def return_404
          head :not_found
        end
      
    end
  end
end