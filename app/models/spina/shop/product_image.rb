module Spina::Shop
  class ProductImage < ApplicationRecord
    PLACEHOLDER = "https://placehold.it/100x100.png"

    belongs_to :product_bundle, optional: true, touch: true
    belongs_to :product, optional: true, touch: true

    scope :ordered, -> { order(:position) }

    after_create :set_filename

    has_one_attached :file

    def description
      product.try(:name)
    end

    def alt
      alt_description.presence || description
    end

    private

      def set_filename
        if file.attached?
          file.blob.update(filename: "#{product.name.parameterize}.#{file.filename.extension}")
        end
      end

  end
end