module Spina
  module Admin
    module Products
      class ProductCategoriesController < ShopController
        before_action :set_breadcrumbs

        def index
          @product_categories = ProductCategory.all
        end

        def show
          @product_category = ProductCategory.find(params[:id])
          add_breadcrumb @product_category.name
        end

        private

          def set_breadcrumbs
            add_breadcrumb Spina::ProductCategory.model_name.human(count: 2), spina.admin_product_categories_path
          end
      end
    end
  end
end