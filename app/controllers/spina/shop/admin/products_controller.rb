module Spina::Shop
  module Admin
    class ProductsController < AdminController
      before_action :set_breadcrumbs
      before_action :set_locale

      def index
        @q = Product.filtered(filters).order(created_at: :desc).includes(:product_images).joins(:translations).where(spina_shop_product_translations: {locale: I18n.locale}).ransack(params[:q])
        @products = @q.result.page(params[:page]).per(25)
        @product_category_properties = Spina::Shop::ProductCategoryProperty.includes(property_options: :translations)

        respond_to do |format|
          format.html
          format.js
          format.json do
            results = @products.includes(:product_images).map do |product|
              { id: product.id, 
                name: product.name, 
                image_url: view_context.attachment_url(product.product_images.first, :file, :fit, 30, 30), 
                price: view_context.number_to_currency(product.price) }
            end
            render inline: {results: results, total_count: @q.result.count}.to_json
          end
        end
      end

      def show
        @product = Product.find(params[:id])
        redirect_to spina.edit_shop_admin_product_path(@product)
      end

      def new_by_category
        @product_categories = ProductCategory.all
      end

      def new
        @product = Product.new
        add_breadcrumb t('spina.shop.products.new'), spina.new_shop_admin_product_path

        @product_category = ProductCategory.where(id: params[:product_category_id]).first

        # Always build at least one product item
        @product.product_category = @product_category
      end

      def create
        @product = Product.new(product_params)
        if @product.save
          redirect_to spina.edit_shop_admin_product_path(@product, params: {locale: @locale})
        else
          render :new
        end
      end

      def edit
        @product = Product.find(params[:id])
        add_breadcrumb @product.name

        @product_category = @product.product_category
      end

      def update
        @product = Product.find(params[:id])
        if I18n.with_locale(@locale) { @product.update_attributes(product_params) }
          redirect_to spina.edit_shop_admin_product_path(@product, params: {locale: @locale})
        else
          render :edit
        end
      end

      def destroy
        @product = Product.find(params[:id])
        @product.destroy
        redirect_to spina.shop_admin_products_path
      rescue ActiveRecord::DeleteRestrictionError
        flash[:alert] = t('spina.shop.products.delete_restriction_error', name: @product.name)
        flash[:alert_small] = t('spina.shop.products.delete_restriction_error_explanation')
        redirect_to spina.shop_admin_product_path(@product)
      end

      private

        def filters
          filter_params.to_h.map do |property, value|
            value.present? ? {field_type: ProductCategoryProperty.find_by(name: property).field_type, property: property, value: value} : {}
          end
        end

        def filter_params
          params.require(:filters).permit! if params[:filters]
        end

        def product_params
          I18n.with_locale I18n.default_locale do
            params.require(:product).permit!.merge(locale: @locale).delocalize({price: :number, cost_price: :number, weight: :number})
          end
        end

        def set_breadcrumbs
          add_breadcrumb Product.model_name.human(count: 2), spina.shop_admin_products_path
        end

        def set_locale
          @locale = params[:locale] || I18n.default_locale
        end
    end
  end
end
