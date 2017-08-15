module Spina::Shop
  class TaxGroup < ApplicationRecord
    # All product items that belong to this tax group
    has_many :products, dependent: :restrict_with_exception
    has_many :delivery_options, dependent: :restrict_with_exception

    has_many :tax_rates, dependent: :destroy

    validates :name, presence: true

    accepts_nested_attributes_for :tax_rates

    def default_tax_rate
      tax_rates.default_rate.first_or_initialize
    end

    # The price modifier for calculating exclusive prices is based on the tax rate.
    # If VAT is reverse charged we will use the default rate to calculate the price ex VAT
    def price_modifier_for_order(order)
      tax_rate = rate_by_order(order)
      rate = order.vat_reverse_charge? ? default_tax_rate.rate : tax_rate.rate
      (rate + BigDecimal.new(100)) / BigDecimal.new(100)
    end

    # Get the rate based on the order
    # 
    # Priority:
    # 1. Get rate by customer group
    # 2. Get rate by zone
    # 3. Default Spina config
    def tax_rate_for_order(order)
      rate_by_order(order).rate || 
        Spina::Shop.config.default_tax_rate
    end

    # Get the tax code based on the order
    # 
    # Priority:
    # 1. Get code by customer group
    # 2. Get code by zone
    # 3. Default Spina config
    def tax_code_for_order(order)
      rate_by_order(order).code || 
        Spina::Shop.config.default_tax_code
    end

    private

      # Get the correct rate by zone
      # 
      # Priority:
      # 1. Match zone
      # 2. Match parent of zone
      # 3. Default zone
      def rate_by_order(o)
        tax_rates.where(tax_rateable: o.delivery_country, business: o.business).first || 
        tax_rates.where(tax_rateable: o.delivery_country.parent, business: o.business).first || 
        default_tax_rate
      end

  end
end