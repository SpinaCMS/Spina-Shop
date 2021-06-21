module Spina::Shop
  class OrderPickListGenerator
    attr_accessor :order
    
    def initialize(order)
      @order = order
    end
    
    def generate!
      clear_order_pick_items
      
      copy_products
      copy_product_bundles
      
      return order if order.save!
    end
    
    private
    
      def clear_order_pick_items
        order.order_pick_items = []
      end
      
      def copy_products
        order.order_items.products.each do |order_item|
          order.order_pick_items << OrderPickItem.new(
            quantity: order_item.quantity,
            product_id: order_item.orderable_id,
            order_item_id: order_item.id
          )
        end
      end
      
      def copy_product_bundles
        order.order_items.product_bundles.each do |order_item|
          order_item.orderable.bundled_products.each do |bundled_product|
            order.order_pick_items << OrderPickItem.new(
              quantity: order_item.quantity * bundled_product.quantity,
              product_id: bundled_product.product_id,
              order_item_id: order_item.id
            )
          end
        end
      end
    
  end
end