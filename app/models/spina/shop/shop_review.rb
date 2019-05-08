module Spina::Shop
  class ShopReview < ApplicationRecord
    belongs_to :order, optional: true
    belongs_to :customer, optional: true
    has_many :product_reviews, dependent: :destroy

    scope :sorted, -> { order(created_at: :desc) }
    scope :approved, -> { where(approved: true) }

    accepts_nested_attributes_for :product_reviews, reject_if: :mostly_blank

    validates :author, :email, :review_pros, :score, presence: true
    validates :score, numericality: {greater_than: 0, less_than_or_equal_to: 10}
    validates :order_id, uniqueness: true, allow_blank: true

    private

      def mostly_blank(attributes)
        attributes['review'].blank? && attributes['review_summary'].blank? && attributes['score'].to_i == 0
      end
  end
end