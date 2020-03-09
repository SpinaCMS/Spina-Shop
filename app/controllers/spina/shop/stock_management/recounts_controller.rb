module Spina::Shop
  module StockManagement
    class RecountsController < StockManagementController
      before_action :set_product, :set_previous_product, :set_next_product

      def new
        @last_recount = @product.recounts.last
      end

      def create
        if recount_params[:stock_levels].any?{|s| s[:stock_level].present?}
          original_stock_level = @product.stock_level.to_i
          recount_stock_level = recount_params[:stock_levels].inject(0){|t,i| t = t + i[:stock_level].to_i} + @reserved
          recount_difference = recount_stock_level - original_stock_level

          @product.transaction do
            # Reset stock to 0
            ChangeStockLevel.new(@product, {
              adjustment: @product.stock_level * -1,
              description: "Recount - Reset",
              actor: current_spina_user.try(:name)
            }).save

            # Add new stock for each in recount_params[:stock_levels]
            stock_levels = recount_params[:stock_levels].sort_by do |stock_level|
              if stock_level[:expiration_month].present? && stock_level[:expiration_year].present?
                Date.parse("01-#{stock_level[:expiration_month]}-#{stock_level[:expiration_year]}")
              end
            end.each do |stock_level|
              next if stock_level[:stock_level].to_i.zero? # Skip any zero stock levels
              ChangeStockLevel.new(@product, {
                adjustment: stock_level[:stock_level],
                description: "Recount",
                expiration_year: stock_level[:expiration_year],
                expiration_month: stock_level[:expiration_month],
                actor: current_spina_user&.name
              }).save
            end

            # Re-add reserved stock
            if @reserved != 0
              ChangeStockLevel.new(@product, {
                adjustment: @reserved,
                description: "Recount - Reserved",
                actor: current_spina_user&.name
              }).save
            end

            # Save as recount
            @product.recounts.create({
              difference: recount_difference, 
              actor: current_spina_user&.name
            })
          end
        else
          @product.recounts.create({difference: 0, actor: current_spina_user&.name})
        end

        redirect_to spina.new_shop_stock_management_product_recount_path(@next_product)
      end

      private

        def set_product
          @product = Product.find_by(id: params[:product_id])
          @reserved = @product.stock_level_adjustments.joins(order_item: :order).where(spina_shop_orders: {id: Spina::Shop::Order.to_process.ids}).sum(:adjustment)
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
          params.require(:product).permit(stock_levels: [:stock_level, :expiration_month, :expiration_year])
        end

    end
  end
end