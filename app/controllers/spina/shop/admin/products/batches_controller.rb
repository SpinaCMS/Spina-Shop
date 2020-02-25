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
          when "product_collections"
            id = params[:product_collection_id]
            if params[:add_or_remove] == "add"
              AddToProductCollectionInBatchJob.perform_later(@products.ids, id)
            elsif params[:add_or_remove] == "remove"
              RemoveFromProductCollectionInBatchJob.perform_later(@products.ids, id)
            end
          when "tags"
            id = params[:tag_id]
            if params[:add_or_remove] == "add"
              AddTagToProductsInBatchJob.perform_later(@products.ids, id)
            elsif params[:add_or_remove] == "remove"
              RemoveTagFromProductsInBatchJob.perform_later(@products.ids, id)
            end
          when "stores"
            id = params[:store_id]
            if params[:add_or_remove] == "add"
              AddToStoreInBatchJob.perform_later(@products.ids, id)
            elsif params[:add_or_remove] == "remove"
              RemoveFromStoreInBatchJob.perform_later(@products.ids, id)
            end
          when "supplier"
            id = params[:supplier_id]
            supplier_packing_unit = params[:supplier_packing_unit]
            AddSupplierToProductsInBatchJob.perform_later(@products.ids, id, supplier_packing_unit)
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
              Product.where(archived: false).filtered(filters).ransack(params[:q]).result
            else
              Product.where(id: params[:product_ids])
            end
          end

          def filters
            filter_params.to_h.map do |property, value|
              value.present? ? {field_type: ProductCategoryProperty.find_by(name: property).field_type, property: property, value: value} : {}
            end
          end

          def filter_params
            params.require(:filters).permit! if params[:filters]
          end

          def pricing_params
            params.permit(:price_for, :price, :price_includes_tax).delocalize(price: :number)
          end

          def product_params
            params.permit(:price, :price_for, :cost_price, :price_includes_tax, :product_category_id, :active, :archived, :weight).delocalize(price: :number, cost_price: :number, weight: :number)
          end

          def property_params
            params.require(:properties).permit!.to_hash
          end

      end
    end
  end
end