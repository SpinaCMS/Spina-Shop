module Spina
  class ProductCategoryProperty < ApplicationRecord
    belongs_to :product_category

    scope :product_type, -> { where(property_type: 'product') }
    scope :item_type, -> { where(property_type: 'item') }

    validates :name, :label, :property_type, :field_type, presence: true

    def options
      read_attribute(:options).try(:split, ',')
    end
  end
end