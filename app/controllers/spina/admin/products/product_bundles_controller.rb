module Spina
  module Admin
    module Products
      class ProductBundlesController < AdminController
        load_and_authorize_resource class: "Spina::ProductBundle"

        before_action :set_breadcrumbs

        def show
          redirect_to edit_admin_product_bundle_path(@product_bundle)
        end

        def new
          add_breadcrumb "Nieuw"
        end

        def create
          if @product_bundle.save
            redirect_to admin_product_bundles_path
          else
            render :new
          end
        end

        def index
        end

        def update
          if @product_bundle.update_attributes(product_bundle_params)
            redirect_to admin_product_bundles_path
          else
            render :edit
          end
        end

        private

          def set_breadcrumbs
            add_breadcrumb "Productbundels", spina.admin_product_bundles_path
          end

          def product_bundle_params
            params.require(:product_bundle).permit(:name, :price, :tax_group_id, :sales_category_id, product_images_attributes: [:id, :position, :_destroy], product_images_files: [], bundled_product_items_attributes: [:id, :quantity, :product_item_id]).delocalize({bundled_product_items_attributes: {price: :number}})
          end
      end
    end
  end
end