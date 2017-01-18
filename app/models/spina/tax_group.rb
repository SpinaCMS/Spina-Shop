module Spina
  class TaxGroup < ApplicationRecord
    # All product items that belong to this tax group
    has_many :product_items, dependent: :restrict_with_exception
    has_many :delivery_options, dependent: :restrict_with_exception

    validates :name, presence: true

    def tax_rate_for_order(order)
      rates_by_country(order.billing_country)['default']['rate'].to_d
    end

    def tax_code_for_order(order)
      rates_by_country(order.billing_country)['default']['tax_code']
    end

    private

      def rates_by_country(country)
        rates = country.eu_member? ? tax_rates['EU'] : tax_rates['default']
        tax_rates[country.code2] || rates || tax_rates['default']
      end

  end
end