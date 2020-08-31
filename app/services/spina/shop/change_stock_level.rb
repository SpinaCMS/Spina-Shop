module Spina::Shop
  class ChangeStockLevel

    def initialize(product, params, send_in_stock_reminders: true)
      @product = product
      @send_in_stock_reminders = send_in_stock_reminders
      @params = {
        product_id: @product.id,
        order_item_id: params[:order_item_id],
        adjustment: params[:adjustment],
        category: params[:category],
        expiration_year: params[:expiration_year],
        expiration_month: params[:expiration_month],
        description: params[:description],
        actor: params[:actor]
      }
    end

    def save
      # Create StockLevelAdjustment
      StockLevelAdjustment.create(@params)

      # Cache product columns for fast querying
      @product.cache_stock_level

      # Stock reminders
      send_in_stock_reminders if @send_in_stock_reminders && @product.in_stock?

      return true
    end

    private

      def send_in_stock_reminders
        InStockReminderJob.perform_later(@product)
      end

  end
end