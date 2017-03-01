module Spina
  module Admin
    class DiscountsController < ShopController
      load_and_authorize_resource class: "Spina::Discount"

      def index
        add_breadcrumb Spina::Discount.model_name.human(count: 2), admin_discounts_path
      end

      def new
      end

      def create
        if @discount.save
          redirect_to admin_discounts_path
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @discount.update_attributes(discount_params)
          redirect_to admin_discounts_path
        else
          render :edit
        end
      end

      def destroy
      end

      private

        def discount_params
          params.require(:discount).permit(:code, discount_action_attributes: [:type, :percent_off, :id], discount_rule_attributes: [:type, :collection_id, :id])
        end

    end
  end
end
