module Spina
  class PropertyOption < ApplicationRecord
    belongs_to :product_category_property

    default_scope -> { order(:name) }

    validates :name, presence: true

    translates :label, fallbacks_for_empty_translations: true

    def label
      read_attribute(:label) || name
    end
  end
end