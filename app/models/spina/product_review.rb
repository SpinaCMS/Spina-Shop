module Spina
  class ProductReview < ApplicationRecord
    belongs_to :product
    belongs_to :customer, optional: true
    belongs_to :shop_review, optional: true

    scope :sorted, -> { order(created_at: :desc) }

    validates :author, :review_summary, :review, :email, :score, presence: true
    validates :score, numericality: {greater_than: 1, less_than_or_equal_to: 10}
    validates :email, email: true, uniqueness: {scope: [:product_id, :customer_id, :shop_review]}

    after_save :cache_product_averages

    private

      def cache_product_averages
        product.save
      end
  end
end