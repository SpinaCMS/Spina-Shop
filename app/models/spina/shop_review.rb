module Spina
  class ShopReview < ApplicationRecord
    belongs_to :order
    belongs_to :customer
    has_many :product_reviews, dependent: :destroy

    accepts_nested_attributes_for :product_reviews, reject_if: :mostly_blank

    validates :author, :email, :review_pros, :review_cons, :score, :score_communication, :score_speed, presence: true
    validates :score, :score_communication, :score_speed, numericality: {greater_than: 1, less_than_or_equal_to: 10}
    validates :order_id, uniqueness: true

    private

      def mostly_blank(attributes)
        attributes['review'].blank? && attributes['review_summary'].blank? && attributes['score'].to_i == 0
      end
  end
end