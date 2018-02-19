module Spina::Shop
  module Admin
    class ProductsController < AdminController
      before_action :set_breadcrumbs
      before_action :set_locale

      def index
        @q = Product.where(archived: false).filtered(filters, hide_variants: false).order(created_at: :desc).includes(:stores, :product_images).joins(:translations).where(spina_shop_product_translations: {locale: I18n.locale}).ransack(params[:q])
        @products = @q.result.page(params[:page]).per(25)
        @product_category_properties = Spina::Shop::ProductCategoryProperty.includes(property_options: :translations)

        respond_to do |format|
          format.html
          format.js
          format.json do
            results = @products.includes(:product_images).map do |product|
              { id: product.id, 
                name: product.name,
                stock_level: (product.stock_level if product.stock_enabled?),
                image_url: view_context.attachment_url(product.product_images.first, :file, :fit, 30, 30), 
                price: view_context.number_to_currency(product.price) }
            end
            render inline: {results: results, total_count: @q.result.count}.to_json
          end
        end
      end

      def archived
        @q = Product.where(archived: true).filtered(filters).order(created_at: :desc).includes(:product_images).joins(:translations).where(spina_shop_product_translations: {locale: I18n.locale}).ransack(params[:q])
        @products = @q.result.page(params[:page]).per(25)
        @product_category_properties = Spina::Shop::ProductCategoryProperty.includes(property_options: :translations)
        render :index
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
        @product_category = @product.product_category
      end

      def update
        @product = Product.find(params[:id])
        if Mobility.with_locale(@locale) { @product.update_attributes(product_params) }
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

      def archive
        @product = Product.find(params[:id])
        @product.update_attributes(archived: true)
        redirect_to spina.shop_admin_product_path(@product)
      end

      def unarchive
        @product = Product.find(params[:id])
        @product.update_attributes(archived: false)
        redirect_to spina.shop_admin_product_path(@product)
      end

      def duplicate
        product = Product.find(params[:id])
        @product = product.dup
        @product_category = product.product_category

        # Duplicate relations
        @product.product_collections = product.product_collections
        @product.related_products = product.related_products

        add_breadcrumb product.name, spina.shop_admin_product_path(product)
        add_breadcrumb t('spina.shop.products.new_copy')

        render :new
      end

      def variant
        product = Product.find(params[:id])
        parent_product = product.parent || product

        @product = parent_product.dup
        @product.assign_attributes(parent_id: parent_product.id, sku: nil, properties: nil)
        @product_category = parent_product.product_category

        @product.product_collections = product.product_collections

        add_breadcrumb parent_product.name, spina.shop_admin_product_path(parent_product)
        add_breadcrumb t('spina.shop.products.new_variant')

        render :new
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
            product_params = params.require(:product).permit!.delocalize(base_price: :number, promotional_price: :number, cost_price: :number, weight: :number)
            if product_params[:price_exceptions].present?
              product_params[:price_exceptions].try(:[], :customer_groups).try(:each) do |price_exception|
                price_exception["price"] = Delocalize::Parsers::Number.new.parse(price_exception["price"])
              end
            else
              product_params[:price_exceptions] = "{}"
            end
            product_params
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
