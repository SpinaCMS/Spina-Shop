module Spina
  class ProductImage < ApplicationRecord
    belongs_to :product
    belongs_to :product_item, optional: true

    scope :ordered, -> { order(:position) }

    attachment :file

    def description
      "#{product.try(:name)} #{product_item.try(:name)}"
    end

    def alt
      alt_description.presence || description
    end
  end
end