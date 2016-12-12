module Spina
  module Admin
    module Products
      class PropertiesController < ShopController
        load_and_authorize_resource :product_category, class: "Spina::ProductCategory"
        load_and_authorize_resource :property, through: :product_category, class: "Spina::ProductCategoryProperty"

        before_action :set_breadcrumbs

        def new
          add_breadcrumb t('spina.shop.properties.new')
        end

        def edit
          add_breadcrumb @property.label
        end

        def create
          @property = ProductCategoryProperty.new(property_params)

          if @property.save
            redirect_to [:admin, @product_category]
          else
            add_breadcrumb t('spina.shop.properties.new')
            render :new
          end
        end

        def update
          @property.assign_attributes(property_params)

          if @property.save
            redirect_to [:admin, @product_category]
          else
            add_breadcrumb @property.label
            render :edit
          end
        end

        def destroy
          @property.destroy!
          redirect_to [:admin, @product_category]
        end

        private

          def set_breadcrumbs
            add_breadcrumb Spina::ProductCategory.model_name.human(count: 2), admin_product_categories_path
            add_breadcrumb @product_category.name, admin_product_category_path(@product_category)
          end

          def property_params
            params.require(:product_category_property).permit(:name, :label, :field_type, :property_type, :options, :minimum, :maximum, :max_characters, :product_category_id, :multiple, :append, :prepend).merge(product_category: @product_category)
          end
      end
    end
  end
end