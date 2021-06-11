module Spina::Shop
  class OrderPickList
    attr_reader :order
    
    def initialize(order)
      @order = order
    end
    
    def items
      products + product_bundles + custom_products
    end
    
    private
    
      def products
        order.order_items.products.includes(:orderable).map do |order_item|
          next if order_item.orderable.nil?
          OpenStruct.new(
            order_id: order.id,
            id: order_item.id.to_s,
            quantity: order_item.quantity,
            name: order_item.description,
            location: order_item.orderable.location,
            ean: order_item.orderable.ean,
            locations: order_item.orderable.product_locations.joins(:location).map do |product_location|
              next if product_location.location_code.blank?
              {
                product_location.location.name => product_location.location_code
              }
            end.compact.reduce({}, :merge)
          )
        end.compact
      end
      
      def product_bundles
        order.order_items.product_bundles.includes(:orderable).map do |order_item|
          order_item.orderable.bundled_products.map.with_index do |bundled_product, index|
            next if bundled_product.product.nil?
            OpenStruct.new(
              order_id: order.id,
              id: "#{order_item.id}-#{index}",
              quantity: bundled_product.quantity * order_item.quantity,
              name: bundled_product.product.name,
              location: bundled_product.product.location,
              ean: bundled_product.product.ean,
              locations: bundled_product.product.product_locations.joins(:location).map do |product_location|
                next if product_location.location_code.blank?
                {
                  product_location.location.name => product_location.location_code
                }
              end.compact.reduce({}, :merge)
            )
          end
        end.flatten.compact
      end
      
      def custom_products
        order.order_items.custom_products.map do |order_item|
          OpenStruct.new(
            order_id: order.id,
            id: order_item.id.to_s,
            quantity: order_item.quantity,
            name: order_item.description,
            location: nil,
            ean: nil,
            locations: []
          )
        end
      end

  end
end