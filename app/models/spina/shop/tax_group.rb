module Spina::Shop
  class TaxGroup < ApplicationRecord
    # All product items that belong to this tax group
    has_many :product_items, dependent: :restrict_with_exception
    has_many :delivery_options, dependent: :restrict_with_exception

    has_many :tax_rates, dependent: :destroy

    validates :name, presence: true

    def tax_rate_for_order(order)
      rate_by_country(order.billing_country).try(:rate)
    end

    def tax_code_for_order(order)
      rate_by_country(order.billing_country).try(:tax_code)
    end

    private

      def rates_by_country(country)
        tax_rates.where(country: country).first ||
        tax_rates.where(country: nil).first
      end

  end
end