module Spina::Shop
  module Admin
    module Stock
      class ReceiveProductsController < AdminController

        def new
          @stock_order = StockOrder.open.find(params[:stock_order_id])
          if params[:ordered_stock_ids].present?
            @ordered_stock = @stock_order.ordered_stock.where(id: params[:ordered_stock_ids])
          else
            @ordered_stock = @stock_order.ordered_stock
          end

        end

        def create
          @stock_order = StockOrder.open.find(params[:stock_order_id])

          # Background job to change stock levels
        end

      end
    end
  end
end