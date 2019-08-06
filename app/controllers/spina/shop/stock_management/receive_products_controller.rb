module Spina::Shop
  module StockManagement
    class ReceiveProductsController < StockManagementController

      def new
        @stock_order = StockOrder.find(params[:stock_order_id])
        @ordered_stock = @stock_order.ordered_stock.find(params[:ordered_stock_id])
      end

      def create
        @stock_order = StockOrder.find(params[:stock_order_id])
        @ordered_stock = @stock_order.ordered_stock.find(params[:ordered_stock_id])

        # Set received and change the stock level
        @ordered_stock.transaction do
          @ordered_stock.received = @ordered_stock.received + params["received"].to_i
          @ordered_stock.save

          # Change stock level
          ChangeStockLevel.new(@ordered_stock.product, {
            adjustment: params["received"].to_i,
            description: "StockOrder ##{@stock_order.id}",
            expiration_month: params["expiration_month"],
            expiration_year: params["expiration_year"],
            actor: current_spina_user.name
          }).save
        end

        redirect_to [spina, :shop, :stock_management, @stock_order]
      end

    end
  end
end