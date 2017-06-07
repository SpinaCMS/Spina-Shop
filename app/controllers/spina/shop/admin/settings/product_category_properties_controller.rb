module Spina::Shop
  module Admin
    module Settings
      class ProductCategoryPropertiesController < ShopController
        layout 'spina/admin/admin'

        before_action :set_product_category
        before_action :set_breadcrumbs, except: [:index]
        before_action :set_locale

        def edit
          @product_category_property = @product_category.properties.find(params[:id])
          add_breadcrumb @product_category_property.label
        end

        def edit_options
          @product_category_property = @product_category.properties.find(params[:id])
          add_breadcrumb @product_category_property.label
        end

        def update
          @product_category_property = @product_category.properties.find(params[:id])
          @product_category_property.update_attributes(product_category_property_params)
          redirect_to [:admin, :settings, @product_category]
        end

        private

          def set_locale
            @locale = params[:locale] || I18n.default_locale
          end

          def set_product_category
            @product_category = ProductCategory.find(params[:product_category_id])
          end

          def set_breadcrumbs
            add_breadcrumb ProductCategory.model_name.human(count: 2), spina.shop_admin_settings_product_categories_path
            add_breadcrumb @product_category.name, [:admin, :settings, @product_category]
          end

          def product_category_property_params
            params.require(:product_category_property).permit(property_options_attributes: [:id, :name, :label, :_destroy]).merge(locale: @locale)
          end

      end
    end
  end
end