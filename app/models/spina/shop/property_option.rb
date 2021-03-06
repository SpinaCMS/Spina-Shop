module Spina::Shop
  class PropertyOption < ApplicationRecord
    belongs_to :property, polymorphic: true

    default_scope -> { order(:name) }

    validates :name, presence: true

    translates :label, fallbacks: I18n.fallbacks
  end
end