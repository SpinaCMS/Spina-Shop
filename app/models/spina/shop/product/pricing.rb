module Spina::Shop
  module Product::Pricing
    extend ActiveSupport::Concern

    included do
      before_validation :set_price_exceptions
    end

    def promotion?
      promotional_price.present?
    end

    def price
      promotional_price.presence || base_price
    end

    def price_for_order(order)
      # Return the default price if we don't know anything about the order
      return price if order.nil? 

      # If no conversion is needed, simply return price
      price = price_for_customer(order.customer)
      price_includes_tax = price_includes_tax_for_customer(order.customer)
      return price if price_includes_tax == order.prices_include_tax

      # Price modifier for unit price
      price_modifier = tax_group.price_modifier_for_order(order)

      # Calculate unit price based on price modifier
      unit_price = price_includes_tax ? price / price_modifier : price * price_modifier

      # Round to two decimals using bankers' rounding
      return unit_price.round(2, :half_even)
    end

    def price_for_customer(customer)
      return price if customer.nil?
      price_exception_for_customer(customer).try(:[], 'price').try(:to_d) || price
    end

    def price_includes_tax_for_customer(customer)
      return price_includes_tax if customer.nil?
      price_exception = price_exception_for_customer(customer)
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

      # Get price exception based on Customer / CustomerGroup if available
      # Try the parent of one's CustomerGroup if present
      # Subgroups are always first
      def price_exception_for_customer(customer)
        return if customer.customer_group_id.blank?
        [customer.customer_group_id, customer.customer_group.parent_id].each do |group_id|
          price_exceptions.try(:[], 'customer_groups').try(:find) do |h|
            return h if h["customer_group_id"].to_i == group_id
          end
        end
      end
  end
end