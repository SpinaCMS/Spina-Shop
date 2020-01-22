module Spina::Shop
  module Admin
    class DiscountsController < AdminController
      before_action :set_discount, only: [:edit, :update, :destroy]
      before_action :set_breadcrumbs

      def index
        if params[:scope] == "one_off"
          @scope = "one_off"
          @discounts = Discount.one_off
        elsif params[:scope] == "auto"
          @scope = "auto"
          @discounts = Discount.auto
        else
          @scope = "multiple_use"
          @discounts = Discount.multiple_use
        end
        
        @discounts = @discounts.ordered
      end

      def new
        @discount = Discount.new(starts_at: Date.today)
        @discount.build_discount_requirement(type: 'Spina::Shop::Discounts::Requirements::AllOrders')
        @discount.build_discount_action
        @discount.build_discount_rule(type: 'Spina::Shop::Discounts::Rules::AllProducts')
        add_breadcrumb t('spina.shop.discounts.new')
      end

      def create
        @discount = Discount.new(discount_params)
        
        if @discount.save
          redirect_to spina.shop_admin_discounts_path
        else
          flash.now[:alert] = "WTF probeer jij nou?!"
          flash.now[:alert_small] = @discount.errors.full_messages.join("<br />")
          add_breadcrumb t('spina.shop.discounts.new')
          render :new
        end
      end

      def edit
        add_breadcrumb @discount.code
      end

      def update
        if @discount.update_attributes(discount_params)
          redirect_to spina.shop_admin_discounts_path
        else
          flash.now[:alert] = "Discount could not be saved"
          flash.now[:alert_small] = @discount.errors.full_messages.join("<br />")
          add_breadcrumb @discount.code
          render :edit
        end
      end

      def destroy
        @discount.destroy
        redirect_to spina.shop_admin_discounts_path
      end

      private

        def set_discount
          @discount = Discount.find(params[:id])
        end

        def set_breadcrumbs
          add_breadcrumb Discount.model_name.human(count: 2), spina.shop_admin_discounts_path
        end

        def discount_params
          params.require(:discount).permit!
        end

    end
  end
end
