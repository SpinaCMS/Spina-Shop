module Spina
  class ProductReview < ApplicationRecord
    belongs_to :reviewable, polymorphic: true
    belongs_to :customer

    before_save :calculate_average_score

    private

      def calculate_average_score
        self.average_score = scores.map{|key, value| [value]}.flatten.reduce(:+) / scores.size.to_f
      end
  end
end