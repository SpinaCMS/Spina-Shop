module Spina::Shop
  class ProductCategory < ApplicationRecord
    has_many :properties, dependent: :destroy, class_name: "Spina::Shop::ProductCategoryProperty"
    has_many :products, dependent: :restrict_with_exception

    validates :name, presence: true, uniqueness: true

    accepts_nested_attributes_for :properties

    def variant_properties
      properties.variant_type
    end

    def product_properties
      properties.product_type
    end
  end
end