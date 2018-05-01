module Spina::Shop
  module Admin
    module Settings
      class SharedPropertiesController < ShopController
        layout 'spina/admin/admin', except: [:index]

        before_action :set_breadcrumbs, except: [:index]
        before_action :set_locale

        def index
          @shared_properties = SharedProperty.order(:name)
        end

        def edit
          @shared_property = SharedProperty.find(params[:id])
          add_breadcrumb @shared_property.name
        end

        def update
          @shared_property = SharedProperty.find(params[:id])
          @shared_property.update_attributes(product_category_property_params)
          redirect_to spina.edit_shop_admin_settings_shared_property_path(@shared_property)
        end

        private

          def set_locale
            @locale = params[:locale] || I18n.default_locale
          end

          def set_breadcrumbs
            add_breadcrumb SharedProperty.model_name.human(count: 2), spina.shop_admin_settings_shared_properties_path
          end

          def product_category_property_params
            params.require(:shared_property).permit(property_options_attributes: [:id, :name, :label, :_destroy])
          end

      end
    end
  end
end