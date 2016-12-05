module Spina
  class TaxGroup < ApplicationRecord
    # All product items that belong to this tax group
    has_many :product_items, dependent: :restrict_with_exception
    has_many :delivery_options, dependent: :restrict_with_exception

    validates :name, presence: true

    def tax_rate_for_order(order)
      rates_by_country(order.billing_country)['default']['rate'].to_d || default_tax_rate
    end

    def vat_code_for_order(order)
      rates_by_country(order.billing_country)['default']['vat_code'] || default_vat_code
    end

    private

      def rates_by_country(country)
        rates = country.eu_member? ? tax_rates['EU'] : tax_rates['default']
        tax_rates[country.iso_3166] || rates || tax_rates['default']
      end

      def default_tax_rate
        BigDecimal(Spina.config.default_tax_rate || 0)
      end

      def default_vat_code
        Spina.config.default_vat_code || "0"
      end
  end
end