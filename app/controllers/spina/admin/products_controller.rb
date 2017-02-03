module Spina
  module Admin
    class ProductsController < ShopController
      before_action :set_breadcrumbs
      before_action :set_locale

      load_and_authorize_resource class: "Spina::Product"

      def index
        @q = Spina::Product.order(:name).ransack(params[:q])
        @products = @q.result.includes(:translations).page(params[:page]).per(25)

        respond_to do |format|
          format.html
          format.js
          format.json do
            results = @products.joins(:product_images).map do |product|
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
        redirect_to edit_admin_product_path(@product)
      end

      def new_by_category
        @product_categories = ProductCategory.all
      end

      def new
        add_breadcrumb t('spina.shop.products.new'), new_admin_product_path

        @product_category = ProductCategory.where(id: params[:product_category_id]).first

        # Always build at least one product item
        @product.product_category = @product_category
        @product.product_items.build
      end

      def create
        if @product.save
          redirect_to edit_admin_product_path(@product, params: {locale: @locale})
        else
          render :new
        end
      end

      def edit
        add_breadcrumb @product.name

        # Always build at least one product item
        @product_category = @product.product_category
        @product.product_items.build if @product.product_items.none?
      end

      def update
        if @product.update_attributes(product_params)
          redirect_to edit_admin_product_path(@product, params: {locale: @locale})
        else
          render :edit
        end
      end

      private

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
