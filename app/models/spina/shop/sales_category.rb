module Spina::Shop
  class SalesCategory < ApplicationRecord

    # Cannot destroy if it has any products or delivery options
    has_many :products, dependent: :restrict_with_exception
    has_many :delivery_options, dependent: :restrict_with_exception

    has_many :sales_category_codes, dependent: :destroy

    validates :name, presence: true

    accepts_nested_attributes_for :sales_category_codes

    def default_code
      sales_category_codes.default_code.first_or_initialize
    end

    # Get the sales code based on the order
    # 
    # Priority:
    # 1. Get code by customer group
    # 2. Get code by zone
    # 3. Default Spina config
    def code_for_order(order)
      code_by_zone(order).code || Spina::Shop.config.default_sales_category_code
    end

    private

      # Get the correct code by zone
      # 
      # Priority:
      # 1. Match zone
      # 2. Match parent of zone
      # 3. Default zone
      def code_by_zone(o)
        sales_category_codes.where(sales_categorizable: o.delivery_country, business: o.business).first ||
        sales_category_codes.where(sales_categorizable: o.delivery_country.parent, business: o.business).first ||
        default_code
      end

  end
end