module Spina::Shop
  module Admin
    module Products
      class BatchesController < AdminController
        helper ProductsHelper

        before_action :set_products

        def edit
          @modal = "#{params[:modal]}_modal"
        end

        def update
          if property_params.present?
            UpdatePropertiesInBatchJob.perform_later(@products.ids, property_params.to_hash)
          else
            UpdateProductsInBatchJob.perform_later(@products.ids, product_params)
          end

          flash[:success] = t('spina.shop.products.batches.updating_html')
          redirect_back fallback_location: spina.shop_admin_products_path
        end

        private

          def set_products
            @products = if params[:select_all]
              Product.where(archived: false).ransack(params[:q]).result
            else
              Product.where(id: params[:product_ids])
            end
          end

          def product_params
            params.permit(:base_price, :cost_price, :price_includes_tax, :active, product_collection_ids: [], store_ids: []).delocalize(base_price: :number, cost_price: :number)
          end

          def property_params
            params.require(:properties).permit(params[:permitted_properties])
          end

      end
    end
  end
end