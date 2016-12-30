module Spina
  class ProductReview < ApplicationRecord
    belongs_to :product
    belongs_to :customer, optional: true

    scope :sorted, -> { order(created_at: :desc) }

    validates :author, :review_summary, :review, :email, :score, presence: true
    validates :email, email: true, uniqueness: {scope: [:product_id, :customer_id]}
  end
end