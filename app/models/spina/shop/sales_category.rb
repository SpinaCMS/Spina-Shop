module Spina::Shop
  class SalesCategory < ApplicationRecord

    # Cannot destroy if it has any products or delivery options
    has_many :product_items, dependent: :restrict_with_exception
    has_many :delivery_options, dependent: :restrict_with_exception

    validates :name, presence: true

    def code_for_order(order)
      default_sales_category_code
    end

    private

      def codes_by_country(country)
        # code = country.eu_member? ? codes['EU'] : codes['default']
        # codes[country.code2] || code || codes['default']
      end

      def default_sales_category_code
        Spina::Shop.config.default_sales_category_code || 0
      end
  end
end