module Spina
  module Admin
    module Products
      class StockLevelAdjustmentsController < ShopController
        before_action :set_product
        before_action :set_product_item

        def index
          @stock_level_adjustments = @product_item.stock_level_adjustments
        end

        def new
          @stock_level_adjustment = @product_item.stock_level_adjustments.build
        end

        def create
          @stock_level_adjustment = @product_item.stock_level_adjustments.build(stock_level_adjustment_params)

          if @stock_level_adjustment.save
            InStockReminderJob.perform_later(@product_item) if params[:send_in_stock_reminders]
            redirect_to [:admin, @product]
          else
            redirect_to [:admin, @product]
          end
        end

        private

          def set_product
            @product = Product.find(params[:product_id])
          end

          def set_product_item
            @product_item = @product.product_items.find(params[:product_item_id])
          end

          def stock_level_adjustment_params
            params.require(:stock_level_adjustment).permit(:adjustment, :description, :expiration_month, :expiration_year).merge(actor: current_user.name, product_item_id: @product_item.id)
          end
      end
    end
  end
end