module Spina::Shop
  module Admin
    module Products
      class StockLevelAdjustmentsController < AdminController
        before_action :set_product

        def index
          @stock_level_adjustments = @product.stock_level_adjustments
        end

        def new
          @stock_level_adjustment = @product.stock_level_adjustments.build
        end

        def create
          @stock_level_adjustment = @product.stock_level_adjustments.build(stock_level_adjustment_params)

          if @stock_level_adjustment.save
            @product.save
            InStockReminderJob.perform_later(@product) if params[:send_in_stock_reminders]
            redirect_to spina.shop_admin_product_path(@product)
          else
            redirect_to spina.shop_admin_product_path(@product)
          end
        end

        private

          def set_product
            @product = Product.find_by(materialized_path: params[:product_id])
          end

          def stock_level_adjustment_params
            params.require(:stock_level_adjustment).permit(:adjustment, :description, :expiration_month, :expiration_year).merge(actor: current_spina_user.name, product_id: @product.id)
          end
      end
    end
  end
end