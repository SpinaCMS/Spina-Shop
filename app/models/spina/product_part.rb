module Spina
  class ProductPart < ApplicationRecord
    belongs_to :product, optional: true

    has_many :page_parts, as: :page_partable, dependent: :destroy
    has_many :layout_parts, as: :layout_partable, dependent: :destroy
    has_many :structure_parts, as: :structure_partable, dependent: :destroy

    def content
      product
    end
  end
end