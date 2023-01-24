module Spina::Shop
  module Product::Pricing
    extend ActiveSupport::Concern

    included do
      before_validation :set_price_exceptions
      before_validation :set_volume_discounts
    end

    def promotion?
      promotional_price.present?
    end

    def price
      promotional_price.presence || base_price
    end

    def price_for_store(store)
      # If there is no store, simply return price
      return price if store.nil?
      price_exception_for_store(store).try(:[], 'price')&.gsub(",", ".")&.to_d || price
    end

    def price_for_order(order, quantity = 1)
      # Return the default price if we don't know anything about the order
      return price if order.nil? 

      # If no conversion is needed, simply return price
      price = price_for_customer(order)
      
      # If tax is not matched with order, convert the price accordingly
      price_includes_tax = price_includes_tax_for_order(order)
      if price_includes_tax != order.prices_include_tax
        # Price modifier for unit price
        price_modifier = tax_group.price_modifier_for_order(order)
        
        # Calculate unit price based on price modifier
        price = price_includes_tax ? price / price_modifier : price * price_modifier
      end
      
      # Volume discount
      price = apply_volume_discount(price, quantity)
      
      return price.round(2, :half_even)
    end

    def price_for_customer(order)
      return price_for_store(order.store) if order.customer.nil?
      price_exception_for_customer(order.customer).try(:[], 'price')&.gsub(",", ".")&.to_d || price_for_store(order.store)
    end

    def price_includes_tax_for_order(order)
      return price_includes_tax if order.nil?
      price_exception = price_exception_for_customer(order.customer) || price_exception_for_store(order.store)
      if price_exception.present?
        ActiveRecord::Type::Boolean.new.cast(price_exception['price_includes_tax'])
      else
        price_includes_tax
      end
    end

    private

      def set_price_exceptions
        self[:price_exceptions] = {
          'stores' => (price_exceptions['stores'].keep_if{|e| e['price'].present? && e['store_id'].present?} if price_exceptions['stores'].try(:any?)),
          'customer_groups' => (price_exceptions['customer_groups'].keep_if{|e| e['price'].present? && e['customer_group_id'].present?} if price_exceptions['customer_groups'].try(:any?))
        }
      end
      
      def set_volume_discounts
        self[:volume_discounts] = (volume_discounts.presence || []).keep_if do |volume_discount|
          volume_discount["quantity"].to_i > 0 && volume_discount["discount"].to_i > 0
        end.sort_by do |volume_discount|
          volume_discount["quantity"].to_i
        end
      end

      # Get price exception based on Customer / CustomerGroup if available
      # Try the parent of one's CustomerGroup if present
      # Subgroups are always first
      def price_exception_for_customer(customer)
        return if customer&.customer_group_id.blank?
        [customer.customer_group_id, customer.customer_group.parent_id].find do |group_id|
          price_exceptions.try(:[], 'customer_groups').try(:find) do |h|
            return h if h["customer_group_id"].to_i == group_id
          end.presence
        end
      end

      # Get price exception based on Store
      def price_exception_for_store(store)
        return if store.nil?
        price_exceptions.try(:[], 'stores')&.find do |h|
          return h if h["store_id"].to_i == store.id
        end.presence
      end
      
      def apply_volume_discount(price, quantity = 1)
        return price unless volume_discounts.present?
        
        volume_discount = volume_discounts.sort_by{|i| i["quantity"].to_i}.reverse.find do |discount|
          quantity >= discount["quantity"].to_i
        end
        
        # Default is no discount
        volume_discount ||= {"discount" => 0}
        
        price * ((100 - volume_discount["discount"].to_d) / 100)
      end

  end
end