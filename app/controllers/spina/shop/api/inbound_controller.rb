module Spina::Shop
  module Api
    class InboundController < ApiController
      
      def show
        @ordered_stock = OrderedStock.find(params[:id])
        render json: {
          name: @ordered_stock.product.full_name,
          product_id: @ordered_stock.product_id,
          location: @ordered_stock.product.location,
          quantity: @ordered_stock.quantity,
          received: @ordered_stock.received,
          ean: @ordered_stock.product.ean
        }
      end
      
    end
  end
end
  