module Spina::Shop
  class ProductReview < ApplicationRecord
    belongs_to :product
    belongs_to :customer, optional: true
    belongs_to :shop_review, optional: true

    scope :sorted, -> { order(created_at: :desc) }

    validates :author, :review_summary, :review, :email, :score, presence: true
    validates :score, numericality: {greater_than: 1, less_than_or_equal_to: 10}
    validates :email, email: true, uniqueness: {scope: [:product_id, :customer_id, :shop_review]}

    after_save :cache_product_review_score
    after_destroy :cache_product_review_score

    private

      def cache_product_review_score
        product.update_attributes(average_review_score: product.product_reviews.average(:score).try(:round, 1))
      end
  end
end