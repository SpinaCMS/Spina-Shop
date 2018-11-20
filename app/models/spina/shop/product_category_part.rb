module Spina::Shop
  class ProductCategoryPart < ApplicationRecord
    belongs_to :product_category, optional: true

    has_many :page_parts, as: :page_partable, class_name: "Spina::PagePart"
    has_many :structure_parts, as: :structure_partable, class_name: "Spina::StructurePart"

    def content
      product_category
    end
  end
end
