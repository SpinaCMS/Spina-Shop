module Spina::Shop
  class ProductImage < ApplicationRecord
    belongs_to :product_bundle, optional: true, touch: true
    belongs_to :product, optional: true, touch: true

    scope :ordered, -> { order(:position) }

    attachment :file, raise_errors: true

    def description
      product.try(:name)
    end

    def alt
      alt_description.presence || description
    end
  end
end