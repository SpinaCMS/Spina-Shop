module Spina::Shop
  module Api
    class RecountController < ApiController
      before_action :set_product
      
      skip_before_action :verify_authenticity_token, only: [:create]
      
      def create
        if recount_params[:stock_levels].any?{|s| s[:stock_level].present?}
          original_stock_level = @product.stock_level.to_i
          recount_stock_level = recount_params[:stock_levels].inject(0){|t,i| t = t + i[:stock_level].to_i} + @reserved
          
          recount_difference = recount_stock_level - original_stock_level

          @product.transaction do
            # Reset stock to 0
            ChangeStockLevel.new(@product, {
              adjustment: @product.stock_level * -1,
              description: "Recount - Reset",
              actor: params[:user]
            }).save

            # Add new stock for each in recount_params[:stock_levels]
            stock_levels = recount_params[:stock_levels].sort_by do |stock_level|
              Date.parse("01-#{stock_level[:expiration_month]}-#{stock_level[:expiration_year]}")
            end.each do |stock_level|
              next if stock_level[:stock_level].to_i.zero? # Skip any zero stock levels
              ChangeStockLevel.new(@product, {
                adjustment: stock_level[:stock_level],
                description: "Recount",
                expiration_year: stock_level[:expiration_year],
                expiration_month: stock_level[:expiration_month],
                actor: params[:user]
              }).save
            end

            # Re-add reserved stock
            if @reserved != 0
              ChangeStockLevel.new(@product, {
                adjustment: @reserved,
                description: "Recount - Reserved",
                actor: params[:user]
              }).save
            end

            # Save as recount
            @product.recounts.create({
              difference: recount_difference, 
              actor: params[:user]
            })
          end
        else
          @product.recounts.create({difference: 0, actor: params[:user]})
        end

        @product.cache_stock_level
        
        head :ok
      end
      
      private
      
        def set_product
          @product = Product.find(params[:product_id])
          @reserved = @product.stock_level_adjustments.reserved.sum(:adjustment)
        end
      
        def recount_params
          params.require(:product).permit(stock_levels: [:stock_level, :expiration_month, :expiration_year])
        end
      
    end
  end
end