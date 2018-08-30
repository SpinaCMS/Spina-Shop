module Spina::Shop
  module Admin
    module Settings
      class TagsController < ShopController
        layout 'spina/admin/admin', except: [:index]

        def index
          @tags = Tag.order(:name)
        end

        def edit
          @tag = Tag.find(params[:id])
          add_breadcrumb Spina::Shop::Tag.model_name.human(count: 2), spina.shop_admin_settings_tags_path
          add_breadcrumb @tag.name
        end

        def new
          @tag = Tag.new
          add_breadcrumb Spina::Shop::Tag.model_name.human(count: 2), spina.shop_admin_settings_tags_path
          add_breadcrumb t('spina.shop.tags.new')
        end

        def create
          @tag = Tag.new(tag_params)

          if @tag.save
            redirect_to spina.shop_admin_settings_tags_path
          else
            add_breadcrumb Spina::Shop::Tag.model_name.human(count: 2), spina.shop_admin_settings_tags_path
            add_breadcrumb t('spina.new')
            render :new
          end
        end

        def update
          @tag = Tag.find(params[:id])

          if @tag.update_attributes(tag_params) 
            redirect_to spina.shop_admin_settings_tags_path
          else
            add_breadcrumb Spina::Shop::Tag.model_name.human(count: 2), spina.shop_admin_settings_tags_path
            add_breadcrumb @tag.name
            render :edit
          end
        end

        def destroy
          @tag = Tag.find(params[:id])
          @tag.destroy
          redirect_to spina.shop_admin_settings_tags_path
        end

        private

          def tag_params
            params.require(:tag).permit(:name)
          end

      end
    end
  end
end