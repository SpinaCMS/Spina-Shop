module Spina::Shop
  module Admin
    module Settings
      class LocationsController < ShopController
        before_action :set_breadcrumbs, except: [:index]

        def index
          @locations = Location.order(:name)
        end

        def new
          @location = Location.new
        end

        def edit
          @location = Location.find(params[:id])
          add_breadcrumb @location.name, spina.shop_admin_settings_location_path(@location)
          add_breadcrumb t('spina.edit')
        end

        def create
          @location = Location.new(location_params)
          if @location.save
            redirect_to spina.shop_admin_settings_locations_path
          else
            render :new
          end
        end

        def update
          @location = Location.find(params[:id])
          if @location.update(location_params)
            redirect_to spina.shop_admin_settings_locations_path
          else
            render :edit
          end
        end

        def destroy
          @location = Location.find(params[:id])
          @location.destroy
          redirect_to spina.shop_admin_settings_locations_path
        end

        private

          def location_params
            params.require(:location).permit(:name)
          end

          def set_breadcrumbs
            add_breadcrumb Location.model_name.human(count: 2), spina.shop_admin_settings_locations_path
          end

      end
    end
  end
end