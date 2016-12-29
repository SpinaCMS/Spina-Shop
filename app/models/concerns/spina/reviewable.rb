require 'active_support/concern'

module Spina
  module Reviewable
    extend ActiveSupport::Concern

    included do
      has_many :product_reviews, as: :reviewable, dependent: :destroy
    end

    def average_review_score
      product_reviews.average(:score).try(:round, 1)
    end
  end
end