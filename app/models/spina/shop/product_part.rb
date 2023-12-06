module Spina::Shop
  class ProductPart < ApplicationRecord
    belongs_to :product, optional: true

    has_many :page_parts, as: :page_partable, dependent: :destroy
    has_many :layout_parts, as: :layout_partable, dependent: :destroy
    has_many :structure_parts, as: :structure_partable, dependent: :destroy

    def content
      product
    end
    
    def convert_to_json!
      part = Spina::Parts::Product.new
      part.product_id = product&.id
      part
    end
    
  end
end