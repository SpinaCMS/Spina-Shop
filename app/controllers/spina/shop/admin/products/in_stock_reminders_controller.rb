module Spina::Shop
  module Admin
    module Products
      class InStockRemindersController < AdminController

        def index
          @product = Product.find(params[:product_id])
          @in_stock_reminders = @product.in_stock_reminders.order(created_at: :desc)
        end

      end
    end
  end
end