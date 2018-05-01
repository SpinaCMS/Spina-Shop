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
          case params[:batch_edit]
          when "pricing"
            # Pricing batch job
            UpdatePricingInBatchJob.perform_later(@products.ids, pricing_params)
          when "property"
            # Update properties in batch
            UpdatePropertiesInBatchJob.perform_later(@products.ids, property_params)
          else
            # Update all other attributes in batch
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

          def pricing_params
            params.permit(:price_for, :price, :price_includes_tax).delocalize(price: :number)
          end

          def product_params
            params.permit(:price, :price_for, :cost_price, :price_includes_tax, :product_category_id, :active, product_collection_ids: [], store_ids: []).delocalize(price: :number, cost_price: :number)
          end

          def property_params
            params.require(:properties).permit!.to_hash
          end

      end
    end
  end
end