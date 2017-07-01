module Spina::Shop
  class ProductImage < ApplicationRecord
    belongs_to :product_bundle, optional: true
    belongs_to :product, optional: true

    scope :ordered, -> { order(:position) }

    attachment :file

    def description
      product.try(:name)
    end

    def alt
      alt_description.presence || description
    end
  end
end