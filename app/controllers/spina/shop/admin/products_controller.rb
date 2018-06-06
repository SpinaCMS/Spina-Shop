module Spina::Shop
  module Admin
    class ProductsController < AdminController
      layout 'spina/admin/admin'

      before_action :set_breadcrumbs
      before_action :set_locale
      before_action :split_search_params

      def index
        pr = if params[:scope] == "purchasable"
          products.where(archived: false).purchasable
        else 
          products.where(archived: false).roots
        end

        # Search for products
        @q = pr.ransack(params[:q])
        @products = @q.result(distinct: true).page(params[:page]).per(10)

        respond_to do |format|
          format.html { render layout: 'spina/shop/admin/products' }
          format.js
          format.json do
            results = @products.map do |product|
              { id:           product.id, 
                name:         params[:scope] == "purchasable" ? product.full_name : product.name,
                stock_level:  (product.stock_level if product.stock_enabled?),
                image_url:    (main_app.url_for(product.product_images.first.file&.variant(resize: '60x60')) if product.product_images.any?),
                price:        view_context.number_to_currency(product.price) }
            end
            render inline: {results: results, total_count: @q.result.count}.to_json
          end
        end
      end

      def archived
        @q = products.where(archived: true).roots.ransack(params[:q])
        @products = @q.result(distinct: true).page(params[:page]).per(10)

        render :index, layout: 'spina/shop/admin/products'
      end

      def translations
        @product = Product.find(params[:id])
      end

      def show
        @product = Product.find(params[:id])
        redirect_to spina.edit_shop_admin_product_path(@product)
      end

      def new_by_category
        @product_categories = ProductCategory.all
      end

      def new
        @product = Product.new(stock_enabled: true)
        add_breadcrumb t('spina.shop.products.new'), spina.new_shop_admin_product_path

        @product.product_category = ProductCategory.where(id: params[:product_category_id]).first
      end

      def create
        @product = Product.new(product_params)

        if @product.save
          attach_product_images
          
          # Save each locale for materialized_path
          Spina.config.locales.each { |l| I18n.with_locale(l) {@product.save} }
          
          redirect_to spina.edit_shop_admin_product_path(@product, params: {locale: @locale})
        else
          render :new
        end
      end

      def edit
        @product = Product.find(params[:id])
      end

      def update
        @product = Product.find(params[:id])
        attach_product_images

        if I18n.with_locale(@locale) { @product.update_attributes(product_params) }
          # Save each locale for materialized_path
          Spina.config.locales.each { |l| I18n.with_locale(l) {@product.save} }

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

        add_breadcrumb parent_product.name, spina.shop_admin_product_path(parent_product)
        add_breadcrumb t('spina.shop.products.new_variant')

        render :new
      end

      private

        def products
          Product.order(created_at: :desc).includes(:stores, :product_images).joins(:translations).where(spina_shop_product_translations: {locale: I18n.locale})
        end

        def split_search_params
          search = :sku_or_location_or_translations_name_cont_all
          if params[:q].try(:[], search).present? && params[:q][search].kind_of?(String)
            params[:q][search] = params[:q][search].split(' ')
          end
        end

        # There's no file validation yet in ActiveStorage
        # We do two things to reduce errors right now:
        # 1. We add accept="image/*" to the image form
        # 2. We destroy the entire record if the uploaded file is not an image
        def attach_product_images
          if params[:product][:files].present?
            @images = params[:product][:files].map do |file|
              # Create the image and attach the file
              image = @product.product_images.create
              image.file.attach(file)

              # Was it not an image after all? DESTROY IT
              image.destroy and next unless image.file.image?

              image
            end.compact
          end
        end

        def product_params
          I18n.with_locale I18n.default_locale do
            params.require(:product).permit!.delocalize(base_price: :number, promotional_price: :number, cost_price: :number, weight: :number)
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
