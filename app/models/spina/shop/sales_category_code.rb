module Spina
  module Shop
    class SalesCategoryCode < ApplicationRecord
      belongs_to :sales_category
      
      # Doesn't have to be polymorphic, these are always ZONES
      belongs_to :sales_categorizable, polymorphic: true, optional: true

      # Category codes without a sales categorizable like a zone is considered the default
      scope :default_code, -> { where(sales_categorizable: nil) }

      validates :code, presence: true
      validates :sales_categorizable_type, uniqueness: {scope: [:sales_category_id, :sales_categorizable_id, :business]}

      # Label of the sales category code is based on the sales categorizable's name
      # Defaults to 'Default sales category code'
      def label
        sales_categorizable.try(:name) || I18n.t('spina.shop.sales_categories.default_sales_category_code')
      end
    end
  end
end