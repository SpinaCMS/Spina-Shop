module Spina
  module Admin
    module Products
      class StockLevelAdjustmentsController < ShopController
        load_and_authorize_resource :product, class: "Spina::Product"
        load_and_authorize_resource :product_item, through: :product, class: "Spina::ProductItem"
        load_and_authorize_resource through: :product_item, class: "Spina::StockLevelAdjustment"

        def index
        end

        def new
        end

        def create
          @stock_level_adjustment = StockLevelAdjustment.new(stock_level_adjustment_params)

          if @stock_level_adjustment.save
            redirect_to [:admin, @product]
          else
            redirect_to [:admin, @product]
          end
        end

        private

          def stock_level_adjustment_params
            params.require(:stock_level_adjustment).permit(:adjustment, :description, :expiration_month, :expiration_year).merge(actor: current_user.name, product_item_id: @product_item.id)
          end
      end
    end
  end
end