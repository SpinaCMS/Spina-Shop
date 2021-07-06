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
          @empty_location_codes = @location.location_codes.where.not(id: not_empty_location_codes)
          
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
        
        private
        
          def set_location
            @location = Location.find(params[:location_id])
          end
        
      end
    end
  end
end