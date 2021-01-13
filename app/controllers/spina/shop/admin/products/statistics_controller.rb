module Spina::Shop
  module Admin
    module Products
      class StatisticsController < AdminController
        before_action :set_product
  
        def index
        end
        
        private
        
          def set_product
            @product = Spina::Shop::Product.find(params[:product_id])
          end
          
      end
    end
  end
end