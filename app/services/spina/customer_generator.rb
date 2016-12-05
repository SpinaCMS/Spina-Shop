module Spina
  class CustomerGenerator
    def initialize(order)
      @order = order
    end

    def generate!
      unless @order.customer.present?
        customer = Customer.create!(
          first_name: @order.first_name,
          last_name: @order.last_name,
          email: @order.email,
          phone: @order.phone,
          date_of_birth: @order.date_of_birth,
          country: @order.billing_country
        )
        @order.customer = customer
        @order.save!
      end
    end

    def generate_with_account!
      generate!
      customer_account = @order.customer.create_customer_account(
        username: @order.email,
        password: @order.password
      )
    end

  end
end