module Spina::Shop
  class ChangeStockLevel

    def initialize(product, params, send_in_stock_reminders: false)
      @product = product
      @send_in_stock_reminders = send_in_stock_reminders
      @params = {
        product_id: @product.id,
        order_item_id: params[:order_item_id],
        adjustment: params[:adjustment],
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
      cache_product_columns

      # Stock reminders
      send_in_stock_reminders if @send_in_stock_reminders && @product.in_stock?

      return true
    end

    private

      def send_in_stock_reminders
        InStockReminderJob.perform_later(@product)
      end

      def cache_product_columns
        @product.update_columns(
          stock_level: @product.stock_level_adjustments.sum(:adjustment),
          expiration_date: @product.can_expire? ? @product.earliest_expiration_date : nil
        )
      end

  end
end