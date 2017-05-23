module Spina
  class PropertyOption < ApplicationRecord
    belongs_to :product_category_property

    default_scope -> { order(:option) }

    validates :option, presence: true
  end
end