module Spina::Shop
  class DuplicateOrder

    def initialize(order)
      @order = order
    end

    def duplicate!
      @order.transaction do
        # Duplicate the order
        @duplicate = Order.create! order_params(@order)
        @duplicate.discount = @order.discount

        # Duplicate order items
        @order.order_items.roots.each do |order_item|
          duplicate_order_item = OrderItem.create! order_item_params(order_item)

          order_item.children.each do |child|
            duplicate_order_item.children.create! order_item_params(child)
          end
        end

        @order.update(duplicate: @duplicate)
        @duplicate
      end
    end

    private

      def order_params(order)
        order.attributes.keep_if{|k|k.in?(order_attributes)}.merge(manual_entry: true)
      end

      def order_item_params(order_item)
        order_item.attributes.keep_if{|k|k.in?(order_item_attributes)}.merge(order_id: @duplicate.id)
      end

      def order_attributes
        contact_attributes + 
        general_attributes + 
        delivery_attributes + 
        billing_attributes + 
        payment_attributes + 
        extra_order_attributes
      end

      def order_item_attributes
        %w(quantity orderable_type orderable_id) + extra_order_item_attributes
      end

      def contact_attributes
        %w(first_name last_name company email phone customer_id date_of_birth)
      end

      def general_attributes
        %w(note reference store_id shift_id )
      end

      def payment_attributes
        %w(pos payment_issuer payment_method prices_include_tax business)
      end

      def delivery_attributes
        address_attributes("delivery") + %w(separate_delivery_address delivery_option_id delivery_name delivery_first_name delivery_last_name delivery_company)
      end

      def billing_attributes
        address_attributes("billing")
      end

      # Override these methods to add extra attributes when duplicating an order
      def extra_order_attributes
        []
      end

      def extra_order_item_attributes
        []
      end

      def address_attributes(prefix)
        attributes = %w(street1 street2 postal_code city house_number house_number_addition country_id)
        attributes.map{|attribute| "#{prefix}_#{attribute}"}
      end

  end
end