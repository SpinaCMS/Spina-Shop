module Spina
  module Admin
    module Products
      class ProductBundlesController < ShopController
        before_action :set_breadcrumbs

        def show
          @product_bundle = ProductBundle.find(params[:id])
          redirect_to edit_admin_product_bundle_path(@product_bundle)
        end

        def new
          @product_bundle = ProductBundle.new
          add_breadcrumb t('spina.shop.product_bundles.new')
        end

        def create
          @product_bundle = ProductBundle.new(product_bundle_params)
          if @product_bundle.save
            redirect_to admin_product_bundles_path
          else
            render :new
          end
        end

        def edit
          @product_bundle = ProductBundle.find(params[:id])
          add_breadcrumb @product_bundle.name
        end

        def index
          @product_bundles = ProductBundle.all
        end

        def update
          @product_bundle = ProductBundle.find(params[:id])
          if @product_bundle.update_attributes(product_bundle_params)
            redirect_to admin_product_bundles_path
          else
            render :edit
          end
        end

        def destroy
          @product_bundle = ProductBundle.find(params[:id])
          @product_bundle.destroy
          redirect_to admin_product_bundles_path
        end

        private

          def set_breadcrumbs
            add_breadcrumb Spina::ProductBundle.model_name.human(count: 2), spina.admin_product_bundles_path
          end

          def product_bundle_params
            params.require(:product_bundle).permit(:name, :price, :tax_group_id, :sales_category_id, product_images_attributes: [:id, :position, :_destroy], product_images_files: [], bundled_product_items_attributes: [:id, :quantity, :product_item_id, :_destroy]).delocalize({bundled_product_items_attributes: {price: :number}})
          end
      end
    end
  end
end