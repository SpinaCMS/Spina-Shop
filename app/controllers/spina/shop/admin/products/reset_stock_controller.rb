module Spina::Shop
  module Admin
    module Products
      class ResetStockController < AdminController
        before_action :set_product

        def new
        end

        def create
          reset_stock_level = reset_params[:stock_level].to_i - @reserved
          original_stock_level = @product.stock_level.to_i

          reset_difference = reset_stock_level - original_stock_level.to_i

          difference_params = {difference: reset_difference, actor: current_spina_user.try(:name) || "onbekend"}

          Product.transaction do
            # Reset stock first
            ChangeStockLevel.new(@product, {
              adjustment: @product.stock_level * -1,
              description: "Stock Management Reset",
              actor: current_spina_user.try(:name)
            }).save

            # Create new stock entry
            ChangeStockLevel.new(@product, {
              adjustment: reset_stock_level,
              description: "Stock Management Recount (#{reset_difference} difference)",
              expiration_year: reset_params[:expiration_year],
              expiration_month: reset_params[:expiration_month],
              actor: current_spina_user.try(:name)
            }).save

            # Save the actual recount
            @product.recounts.create(difference_params)
          end

          redirect_to spina.edit_shop_admin_product_path(@product)
        end

        private

          def set_product
            @product = Product.find(params[:product_id])
            @reserved = -1 * @product.stock_level_adjustments.joins(order_item: :order).where(spina_shop_orders: {id: Spina::Shop::Order.to_process.ids}).sum(:adjustment)
          end

          def reset_params
            params.require(:product).permit(:stock_level, :expiration_year, :expiration_month)
          end

      end
    end
  end
end