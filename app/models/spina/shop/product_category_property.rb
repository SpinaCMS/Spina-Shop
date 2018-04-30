module Spina::Shop
  class ProductCategoryProperty < ApplicationRecord
    belongs_to :product_category
    has_many :property_options, as: :property, dependent: :destroy

    # Shared property
    belongs_to :shared_property, optional: true

    scope :product_type, -> { where(property_type: 'product') }
    scope :variant_type, -> { where(property_type: 'variant') }

    validates :name, :label, :property_type, :field_type, presence: true
    validates :name, uniqueness: {scope: :product_category_id}

    accepts_nested_attributes_for :property_options, allow_destroy: true, reject_if: :all_blank

    def property_options
      shared_property&.property_options || super
    end
  end
end