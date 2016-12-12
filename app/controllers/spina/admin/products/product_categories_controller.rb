module Spina
  module Admin
    module Products
      class ProductCategoriesController < ShopController
        load_and_authorize_resource class: "Spina::ProductCategory"

        before_action :set_breadcrumbs

        def index
        end

        def show
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