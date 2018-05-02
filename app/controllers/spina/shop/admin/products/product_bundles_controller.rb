module Spina::Shop
  module Admin
    module Products
      class ProductBundlesController < AdminController
        before_action :set_breadcrumbs
        before_action :set_locale

        def show
          @product_bundle = ProductBundle.find(params[:id])
          redirect_to spina.edit_shop_admin_product_bundle_path(@product_bundle)
        end

        def new
          @product_bundle = ProductBundle.new
          add_breadcrumb t('spina.shop.product_bundles.new')
        end

        def create
          @product_bundle = ProductBundle.new(product_bundle_params)
          if @product_bundle.save
            attach_product_images
            redirect_to spina.edit_shop_admin_product_bundle_path(@product_bundle)
          else
            render :new
          end
        end

        def edit
          @product_bundle = ProductBundle.find(params[:id])
          add_breadcrumb @product_bundle.name
        end

        def index
          @q = ProductBundle.includes(:product_images).joins(:translations).where(spina_shop_product_bundle_translations: {locale: I18n.locale}).ransack(params[:q])
          @product_bundles = @q.result.page(params[:page]).per(25).order(created_at: :desc)

          respond_to do |format|
            format.html { render layout: 'spina/shop/admin/products' }
            format.js
            format.json do
              results = @product_bundles.map do |product_bundle|
              { id: product_bundle.id, 
                name: product_bundle.name,
                stock_level: product_bundle.stock_level,
                image_url: view_context.attachment_url(product_bundle.product_images.first, :file, :fit, 30, 30), 
                price: view_context.number_to_currency(product_bundle.price) }
            end
            render inline: {results: results, total_count: @q.result.count}.to_json
            end
          end
        end

        def update
          @product_bundle = ProductBundle.find(params[:id])
          attach_product_images
          if I18n.with_locale(@locale) { @product_bundle.update_attributes(product_bundle_params) }
            redirect_to spina.edit_shop_admin_product_bundle_path(@product_bundle, params: {locale: @locale})
          else
            render :edit
          end
        end

        def destroy
          @product_bundle = ProductBundle.find(params[:id])
          @product_bundle.destroy
          redirect_to spina.shop_admin_product_bundles_path
        end

        private

          def attach_product_images
            if params[:product_bundle][:files].present?
              @images = params[:product_bundle][:files].map do |file|
                image = @product_bundle.product_images.create
                image.file.attach(file)
                image
              end
            end
          end

          def set_breadcrumbs
            add_breadcrumb ProductBundle.model_name.human(count: 2), spina.shop_admin_product_bundles_path
          end

          def set_locale
            @locale = params[:locale] || I18n.default_locale
          end

          def product_bundle_params
            params.require(:product_bundle).permit(:name, :description, :seo_title, :seo_description, :active, :price, :original_price, :tax_group_id, :sales_category_id, product_images_attributes: [:id, :position, :_destroy], product_images_files: [], bundled_products_attributes: [:id, :quantity, :product_id, :_destroy]).delocalize({price: :number, original_price: :number})
          end
      end
    end
  end
end