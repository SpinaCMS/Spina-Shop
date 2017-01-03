module Spina
  class ProductItem < ApplicationRecord
    belongs_to :product
    belongs_to :tax_group
    belongs_to :sales_category

    has_many :order_items, as: :orderable, dependent: :restrict_with_exception # Don't destroy product if it has order items
    has_many :stock_level_adjustments, dependent: :destroy

    # Product bundles
    has_many :bundled_product_items, dependent: :destroy
    has_many :product_bundles, through: :bundled_product_items, dependent: :restrict_with_exception

    # Cache product averages
    after_save :cache_product_averages

    validates :tax_group, :price, presence: true

    def description
      [product.name, name].compact.join(', ')
    end

    def stock_level
      stock_level_adjustments.sum(:adjustment)
    end

    def product_images
      product.product_images
    end

    def weight
      read_attribute(:weight) || BigDecimal(0)
    end

    private

      def cache_product_averages
        product.save
      end
  end
end