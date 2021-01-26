module Spina::Shop
  module Admin
    module Products
      class SalesController < AdminController
        before_action :set_product
        
        def show
          @weekly_sales = @product.sales_per_week.to_a.reverse
        end
        
        private
        
          def set_product
            @product = Spina::Shop::Product.find(params[:product_id])
          end
          
      end
    end
  end
end