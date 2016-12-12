module Spina
  module Admin
    module Products
      class ProductItemsController < ShopController
        load_and_authorize_resource :product, class: "Spina::Product"
        load_and_authorize_resource through: :product, class: "Spina::ProductItem"

        before_action :set_breadcrumbs
        before_action :set_locale

        def new
          add_breadcrumb t('spina.shop.product_items.new')
          @product_category = @product.product_category
        end

        def create
          if @product_item.save
            redirect_to edit_admin_product_product_item_path(@product, @product_item, params: {locale: @locale})
          else
            render :new
          end
        end

        def edit
          add_breadcrumb @product_item.name
          @product_category = @product.product_category
        end

        def update
          if @product_item.update_attributes(product_item_params)
            redirect_to edit_admin_product_product_item_path(@product, @product_item, params: {locale: @locale})
          else
            render :edit
          end
        end

        private

          def product_item_params
            params.require(:product_item).permit!.merge(locale: @locale)
          end

          def set_breadcrumbs
            add_breadcrumb Spina::Product.model_name.human(count: 2), admin_products_path
            add_breadcrumb @product.name, admin_product_path(@product)
          end

          def set_locale
            @locale = params[:locale] || I18n.default_locale
          end

      end
    end
  end
end