module Spina::Shop
  module Admin
    module Products
      class ProductLocationsController < AdminController
        before_action :set_product
        
        def new
          @product_location = @product.product_locations.new(location_id: params[:location_id])
        end
        
        def create
          @product_location = ProductLocation.new(product_location_params)
          if @product_location.save
          else
          end
          redirect_to spina.edit_shop_admin_product_path(@product)
        end
        
        def edit
          @product_location = @product.product_locations.find(params[:id])
        end
        
        def update
          @product_location = @product.product_locations.find(params[:id])
          @product_location.update(product_location_params)
          redirect_to spina.edit_shop_admin_product_path(@product)
        end
        
        def destroy
          @product_location = @product.product_locations.find(params[:id])
          @product_location.destroy
          redirect_to spina.edit_shop_admin_product_path(@product)
        end
        
        private
        
          def set_product
            @product = Product.find(params[:product_id])
          end
        
          def product_location_params
            params.require(:product_location).permit(:location_code_id, :location_id, :stock_level).merge(product_id: @product.id)
          end
        
      end
    end
  end
end