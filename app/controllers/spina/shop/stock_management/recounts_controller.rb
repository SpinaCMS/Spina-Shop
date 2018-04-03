module Spina::Shop
  module StockManagement
    class RecountsController < StockManagementController
      before_action :set_product

      def new
      end

      def create
        original_stock_level = @product.stock_level
        recount_difference = recount_params[:stock_level].to_i - original_stock_level

        if original_stock_level != recount_params[:stock_level].to_i || recount_params[:expiration_year].to_i != @product.expiration_year || recount_params[:expiration_month].to_i != @product.expiration_month

          # Reset stock first
          reset = ChangeStockLevel.new(@product, {
            adjustment: @product.stock_level * -1,
            description: "Stock Management Reset",
            actor: current_spina_user.try(:name)
          })

          # Create new stock entry
          entry = ChangeStockLevel.new(@product, {
            adjustment: recount_params[:stock_level],
            description: "Stock Magenement Recount (#{recount_difference} difference)",
            expiration_year: recount_params[:expiration_year],
            expiration_month: recount_params[:expiration_month],
            actor: current_spina_user.try(:name)
          })

          if reset.save && entry.save
            redirect_to spina.shop_stock_management_products_path
          else
            render :new
          end
        else
          redirect_to spina.shop_stock_management_products_path
        end
      end

      private

        def set_product
          @product = Product.find(params[:product_id])
        end

        def recount_params
          params.require(:product).permit(:stock_level, :expiration_year, :expiration_month)
        end

    end
  end
end