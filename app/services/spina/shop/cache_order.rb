module Spina::Shop
  class CacheOrder

    def initialize(order)
      @order = order
    end

    def cache
      # Cache each item first
      cache_order_items

      # Cache delivery option
      cache_delivery_option if @order.delivery_option.present?
    end

    private

      def cache_order_items
        @order.order_items.each do |item|
          item.write_attribute :weight, item.weight
          item.write_attribute :unit_price, item.unit_price
          item.write_attribute :unit_cost_price, item.unit_cost_price
          item.write_attribute :tax_rate, item.tax_rate
          item.write_attribute :discount_amount, item.discount_amount
          item.write_attribute :metadata, {
            tax_code: item.orderable.tax_group.tax_code_for_order(@order),
            sales_category_code: item.orderable.sales_category.code_for_order(@order)
          }
        end
        @order.order_items.each do |item|
          item.save(validate: false)
        end
      end

      def cache_delivery_option
        @order.update_columns(
          delivery_price: @order.delivery_price,
          delivery_tax_rate: @order.delivery_tax_rate,
          delivery_metadata: {
            tax_code: @order.delivery_option.tax_group.tax_code_for_order(@order),
            sales_category_code: @order.delivery_option.sales_category.code_for_order(@order)  
          }
        )
      end

  end
end