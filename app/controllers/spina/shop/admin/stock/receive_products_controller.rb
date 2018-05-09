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

          StockOrder.transaction do
            params[:ordered_stock].each do |ordered_stock_param|
              # Update ordered stock
              ordered_stock = @stock_order.ordered_stock.find(ordered_stock_param["id"])
              ordered_stock.received = ordered_stock.received + ordered_stock_param["received"].to_i
              ordered_stock.save

              # Change stock level
              ChangeStockLevel.new(ordered_stock.product, {
                adjustment: ordered_stock_param["received"].to_i,
                description: "StockOrder ##{@stock_order.id}",
                actor: current_spina_user.name
              }).save
            end
          end

          redirect_to spina.shop_admin_stock_order_path(@stock_order)
        end

      end
    end
  end
end