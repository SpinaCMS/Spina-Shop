module Spina::Shop
  module Admin
    module Settings
      class LocationCodesController < ShopController
        before_action :set_location
        
        def index
          @q = @location.location_codes.ransack(params[:q])
          @location_codes = @q.result.order(:code).page(params[:page]).per(25)
          
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