module Spina
  class ProductReview < ApplicationRecord
    belongs_to :reviewable, polymorphic: true
    belongs_to :customer, optional: true

    scope :sorted, -> { order(created_at: :desc) }

    validates :author, :review_summary, :review, :email, :score, presence: true
    validates :email, email: true, uniqueness: {scope: [:reviewable_id, :reviewable_type, :customer_id]}
  end
end