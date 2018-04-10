module Spina::Shop
  module StockManagement
    class RecountsController < StockManagementController
      before_action :set_product, :set_previous_product, :set_next_product

      def new
        @last_recount = @product.recounts.last
      end

      def create
        original_stock_level = @product.stock_level.to_i
        recount_difference = recount_params[:stock_level].to_i - original_stock_level.to_i
        something_changed = (recount_difference != 0) || (recount_params[:expiration_year].to_i != @product.expiration_year.to_i) || (recount_params[:expiration_month].to_i != @product.expiration_month.to_i)
        difference_params = {difference: recount_difference, actor: current_spina_user.try(:name) || "onbekend"}

        if something_changed
          Product.transaction do
            # Reset stock first
            ChangeStockLevel.new(@product, {
              adjustment: @product.stock_level * -1,
              description: "Stock Management Reset",
              actor: current_spina_user.try(:name)
            }).save

            # Create new stock entry
            ChangeStockLevel.new(@product, {
              adjustment: recount_params[:stock_level],
              description: "Stock Management Recount (#{recount_difference} difference)",
              expiration_year: recount_params[:expiration_year],
              expiration_month: recount_params[:expiration_month],
              actor: current_spina_user.try(:name)
            }).save

            # Save the actual recount
            @product.recounts.create(difference_params)
          end
        else
          # Save an empty recount
          @product.recounts.create(difference_params)
        end
        redirect_to spina.new_shop_stock_management_product_recount_path(@next_product)
      end

      private

        def set_product
          @product = Product.find_by(id: params[:product_id])
        end

        def set_previous_product
          @previous_product = Product.find_by(id: all_product_ids[current_index - 1])
        end

        def set_next_product
          @next_product = Product.find_by(id: all_product_ids[current_index + 1])
        end

        def current_index
          @index ||= all_product_ids.index(@product.id)
        end

        def all_product_ids
          @all_product_ids ||= Product.active.where.not(location: "").order(:location).ids
        end

        def recount_params
          params.require(:product).permit(:stock_level, :expiration_year, :expiration_month)
        end

    end
  end
end