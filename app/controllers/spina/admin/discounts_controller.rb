module Spina
  module Admin
    class DiscountsController < AdminController
      before_action :set_discount, only: [:edit, :update, :destroy]
      before_action :set_breadcrumbs

      def index
        @discounts = Spina::Discount.all
      end

      def new
        @discount = Spina::Discount.new(starts_at: Date.today)
        @discount.build_discount_action(type: 'Spina::Discounts::Actions::PercentOff')
        @discount.build_discount_rule(type: 'Spina::Discounts::Rules::AllOrders')
        add_breadcrumb t('spina.shop.discounts.new')
      end

      def create
        @discount = Spina::Discount.new(discount_params)
        
        if @discount.save
          redirect_to admin_discounts_path
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
          redirect_to admin_discounts_path
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
          @discount = Spina::Discount.find(params[:id])
        end

        def set_breadcrumbs
          add_breadcrumb Spina::Discount.model_name.human(count: 2), admin_discounts_path
        end

        def discount_params
          params.require(:discount).permit(:code, :starts_at, :expires_at, :description, discount_action_attributes: [:type, :percent_off, :id], discount_rule_attributes: [:type, :collection_id, :id])
        end

    end
  end
end
