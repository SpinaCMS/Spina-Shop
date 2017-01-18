module Spina
  class ProductItem < ApplicationRecord
    belongs_to :product, inverse_of: :product_items
    belongs_to :tax_group
    belongs_to :sales_category

    has_many :order_items, as: :orderable, dependent: :restrict_with_exception # Don't destroy product if it has order items
    has_many :stock_level_adjustments, dependent: :destroy

    # Product bundles
    has_many :bundled_product_items, dependent: :destroy
    has_many :product_bundles, through: :bundled_product_items, dependent: :restrict_with_exception

    # Cache product averages
    before_save :cache_averages
    after_save :cache_product_averages

    validates :tax_group, :price, presence: true

    def description
      [product.name, name].compact.join(', ')
    end

    def product_images
      product.product_images
    end

    def weight
      read_attribute(:weight) || BigDecimal(0)
    end

    private

      def earliest_expiration_date
        offset = 0
        sum = 0
        adjustment = stock_level_adjustments.ordered.additions.offset(offset).first
        while sum < stock_level || (adjustment && adjustment == stock_level_adjustments.ordered.additions.last) do
          adjustment = stock_level_adjustments.ordered.additions.offset(offset).first
          offset = offset.next
          sum = sum + adjustment.try(:adjustment).to_i
        end 

        if adjustment.try(:expiration_year).present?
          Date.new.change(day: 1, month: adjustment.expiration_month || 1, year: adjustment.expiration_year)
        else
          nil
        end
      end

      def cache_averages
        write_attribute :stock_level, stock_level_adjustments.sum(:adjustment)
        write_attribute :expiration_date, can_expire? ? earliest_expiration_date : nil
      end

      def cache_product_averages
        product.save
      end
  end
end