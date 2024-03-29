module Spina::Shop
  class OrderPickList
    attr_reader :order
    
    def initialize(order)
      @order = order
    end
    
    def items
      if order.order_pick_items.any?
        order_pick_items
      else
        products + product_bundles + custom_products
      end
    end
    
    private
    
      def order_pick_items
        order.order_pick_items.joins(:product, :order_item).includes(product: :translations).map do |order_pick_item|
          OpenStruct.new(
            id: order_pick_item.id,
            quantity: order_pick_item.quantity,
            order_id: order_pick_item.order_id,
            order_item_id: order_pick_item.order_item_id,
            name: order_pick_item.product.full_name,
            ean: order_pick_item.product.ean,
            location: order_pick_item.product.location,
            stock_level: order_pick_item.product.stock_level,
            locations: order_pick_item.product.product_locations.joins(:location).where(spina_shop_locations: {primary: false}).map do |product_location|
              next if product_location.location_code.nil?
              {
                name: product_location.location.name,
                location_code: product_location.location_code.to_s,
                stock_level: product_location.stock_level
              }
            end.compact
          )
        end
      end
    
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
            order_item_id: nil,
            stock_level: order_item.orderable.stock_level,
            locations: order_item.orderable.product_locations.joins(:location).where(spina_shop_locations: {primary: false}).map do |product_location|
              next if product_location.location_code.nil?
              {
                name: product_location.location.name,
                location_code: product_location.location_code.to_s,
                stock_level: product_location.stock_level
              }
            end.compact
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
              order_item_id: nil,
              quantity: bundled_product.quantity * order_item.quantity,
              name: bundled_product.product.name,
              location: bundled_product.product.location,
              ean: bundled_product.product.ean,
              stock_level: bundled_product.product.stock_level,
              locations: bundled_product.product.product_locations.joins(:location).where(spina_shop_locations: {primary: false}).map do |product_location|
                next if product_location.location_code.nil?
                {
                  name: product_location.location.name,
                  location_code: product_location.location_code.to_s,
                  stock_level: product_location.stock_level
                }
              end.compact
            )
          end
        end.flatten.compact
      end
      
      def custom_products
        order.order_items.custom_products.map do |order_item|
          OpenStruct.new(
            order_id: order.id,
            id: order_item.id.to_s,
            order_item_id: nil,
            quantity: order_item.quantity,
            name: order_item.description,
            stock_level: nil,
            location: nil,
            ean: nil,
            locations: []
          )
        end
      end

  end
end