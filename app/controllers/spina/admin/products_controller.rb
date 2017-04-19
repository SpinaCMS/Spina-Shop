module Spina
  module Admin
    class ProductsController < ShopController
      before_action :set_breadcrumbs
      before_action :set_locale

      def index
        @q = Spina::Product.filtered(filters).order(created_at: :desc).includes(:translations, :product_items).where(spina_product_translations: {locale: I18n.locale}).ransack(params[:q])
        @products = @q.result.page(params[:page]).per(25)

        respond_to do |format|
          format.html
          format.js
          format.json do
            results = @products.includes(:product_images).map do |product|
              { id: product.id, 
                name: product.name, 
                image_url: view_context.attachment_url(product.product_images.first, :file, :fit, 30, 30), 
                price: view_context.number_to_currency(product.lowest_price) }
            end
            render inline: {results: results, total_count: @q.result.count}.to_json
          end
        end
      end

      def show
        @product = Product.find(params[:id])
        redirect_to edit_admin_product_path(@product)
      end

      def new_by_category
        @product_categories = ProductCategory.all
      end

      def new
        @product = Product.new
        add_breadcrumb t('spina.shop.products.new'), new_admin_product_path

        @product_category = ProductCategory.where(id: params[:product_category_id]).first

        # Always build at least one product item
        @product.product_category = @product_category
        @product.product_items.build
      end

      def create
        @product = Product.new(product_params)
        if @product.save
          redirect_to edit_admin_product_path(@product, params: {locale: @locale})
        else
          render :new
        end
      end

      def edit
        @product = Product.find(params[:id])
        add_breadcrumb @product.name

        # Always build at least one product item
        @product_category = @product.product_category
        @product.product_items.build if @product.product_items.none?
      end

      def update
        @product = Product.find(params[:id])
        if @product.update_attributes(product_params)
          redirect_to edit_admin_product_path(@product, params: {locale: @locale})
        else
          render :edit
        end
      end

      def destroy
        @product = Product.find(params[:id])
        @product.destroy
        redirect_to admin_products_path
      rescue ActiveRecord::DeleteRestrictionError
        flash[:alert] = t('spina.shop.products.delete_restriction_error', name: @product.name)
        flash[:alert_small] = t('spina.shop.products.delete_restriction_error_explanation')
        redirect_to [:admin, @product]
      end

      private

        def filters
          filter_params.to_h.map do |property, value|
            value.present? ? {field_type: Spina::ProductCategoryProperty.find_by(name: property).field_type, property: property, value: value} : {}
          end
        end

        def filter_params
          params.require(:filters).permit! if params[:filters]
        end

        def product_params
          params.require(:product).permit!.merge(locale: @locale).delocalize({product_items_attributes: {price: :number, cost_price: :number, weight: :number}})
        end

        def set_breadcrumbs
          add_breadcrumb Spina::Product.model_name.human(count: 2), admin_products_path
        end

        def set_locale
          @locale = params[:locale] || I18n.default_locale
        end
    end
  end
end
