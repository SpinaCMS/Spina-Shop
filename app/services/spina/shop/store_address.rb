module Spina::Shop
  class StoreAddress

    def initialize(order)
      @order = order
    end

    def store!
      @order.customer.addresses.create(
        first_name: @order.first_name,
        last_name: @order.last_name,
        postal_code: @order.billing_postal_code,
        city: @order.billing_city,
        country_id: @order.billing_country_id,
        house_number: @order.billing_house_number,
        house_number_addition: @order.billing_house_number_addition,
        street1: @order.billing_street1,
        street2: @order.billing_street2
      )
    end

  end
end