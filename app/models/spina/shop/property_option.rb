module Spina::Shop
  class PropertyOption < ApplicationRecord
    belongs_to :product_category_property

    default_scope -> { order(:name) }

    validates :name, presence: true

    translates :label

    def label
      read_attribute(:label) || name
    end
  end
end