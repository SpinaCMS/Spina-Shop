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
      # Priority for business orders:
      # 1. Match zone with business = true
      # 2. Match parent of zone with business = true
      # 3. Match zone with business = false
      # 4. Match parent of zone with business = false
      # 5. Default zone
      # 
      # Priority for other orders:
      # 1. Match zone with business = false
      # 2. Match parent of zone with business = false
      # 3. Default zone
      def code_by_zone(o)
        where = {sales_categorizable: [o.delivery_country, o.delivery_country.parent].compact}
        where[:business] = false unless o.business?
        order = Arel.sql("
          business DESC, 
          CASE WHEN 
            sales_categorizable_id = '#{o.delivery_country.id}'
          THEN 0 ELSE 1 END")

        sales_category_codes.where(where).order(order).first || default_code
      end

  end
end