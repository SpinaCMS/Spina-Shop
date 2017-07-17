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
          change = ChangeStockLevel.new(@product, stock_level_adjustment_params, send_in_stock_reminders: params[:send_in_stock_reminders])
          change.save
          redirect_to spina.shop_admin_product_path(@product)
        end

        private

          def set_product
            @product = Product.find(params[:product_id])
          end

          def stock_level_adjustment_params
            params.require(:stock_level_adjustment).permit(:adjustment, :description, :expiration_month, :expiration_year).merge(actor: current_spina_user.name)
          end
      end
    end
  end
end