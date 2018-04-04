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

        if original_stock_level != recount_params[:stock_level].to_i || recount_params[:expiration_year].to_i != @product.expiration_year.to_i || recount_params[:expiration_month].to_i != @product.expiration_month.to_i

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
            @product.recounts.create({difference: recount_difference, actor: current_spina_user.try(:name) || "onbekend"})
            redirect_to spina.new_shop_stock_management_product_recount_path(@next_product)
          else
            render :new
          end
        else
          @product.recounts.create({difference: recount_difference, actor: current_spina_user.try(:name) || "onbekend"})
          redirect_to spina.new_shop_stock_management_product_recount_path(@next_product)
        end
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