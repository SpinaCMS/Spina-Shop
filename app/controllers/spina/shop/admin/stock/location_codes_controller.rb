module Spina::Shop
  module Admin
    module Stock
      class LocationCodesController < AdminController
        layout 'spina/shop/admin/stock'
        
        before_action :set_location
        
        def index
          add_breadcrumb "Locaties"
          add_breadcrumb @location.name
          
          @q = @location.location_codes.ransack(params[:q])
          @location_codes = @q.result.includes(products: :translations).order(:code).page(params[:page]).per(25)
          
          not_empty_location_codes = @location.location_codes.joins(product_locations: :product).ids
          @empty_location_codes = @location.location_codes.where.not(id: not_empty_location_codes).order(:code)
          
          unless @location.primary?
            @out_of_stock_location_codes = @location.location_codes.where(spina_shop_product_locations: {stock_level: 0}).joins(product_locations: :product)
          end
          
          respond_to do |format|
            format.json do
              results = @location_codes.map do |location_code|
                { id: location_code.id, code: location_code.code, product_count: location_code.products.count }
              end
              render inline: {results: results, total_count: @q.result.count}.to_json
            end
            format.html
          end
        end
        
        def new
          @location_code = @location.location_codes.new
        end
        
        def create
          @location_code = LocationCode.new(location_code_params)
          if @location_code.save
            redirect_to spina.shop_admin_location_location_codes_path(@location)
          else
            render :new
          end
        end
        
        def destroy
          @location_code = @location.location_codes.find(params[:id])
          if @location_code.products.none?
            @location_code.destroy
          end
          redirect_to spina.shop_admin_location_location_codes_path(@location)
        end
        
        private
        
          def set_location
            @location = Location.find(params[:location_id])
          end
          
          def location_code_params
            params.require(:location_code).permit(:code).merge(location_id: @location.id)
          end
        
      end
    end
  end
end