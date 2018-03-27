module Spina::Shop
  module Admin
    class DiscountsController < AdminController
      before_action :set_discount, only: [:edit, :update, :destroy]
      before_action :set_breadcrumbs

      def index
        if params[:scope] == "one_off"
          @scope = "one_off"
          @discounts = Discount.one_off
        else
          @scope = "multiple_use"
          @discounts = Discount.multiple_use
        end
      end

      def new
        @discount = Discount.new(starts_at: Date.today)
        @discount.build_discount_action(type: 'Spina::Shop::Discounts::Actions::PercentOff')
        @discount.build_discount_rule(type: 'Spina::Shop::Discounts::Rules::AllOrders')
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
      end

      private

        def set_discount
          @discount = Discount.find(params[:id])
        end

        def set_breadcrumbs
          add_breadcrumb Discount.model_name.human(count: 2), spina.shop_admin_discounts_path
        end

        def discount_params
          params.require(:discount).permit(:code, :starts_at, :expires_at, :description, :usage_limit, discount_action_attributes: [:type, :percent_off, :id], discount_rule_attributes: [:type, :collection_id, :id])
        end

    end
  end
end
