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

      # Cache payment method
      cache_payment_method if @order.payment_method.present?
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

      def cache_payment_method
        @order.update_columns(
          payment_method_price: @order.payment_method_price,
          payment_method_tax_rate: @order.payment_method_tax_rate,
          payment_method_metadata: {
            tax_code: @order.payment_method.tax_group.tax_code_for_order(@order),
            sales_category_code: @order.payment_method.sales_category.code_for_order(@order)  
          }
        )
      end

  end
end