module Spina::Shop
  class Tag < ApplicationRecord
    extend Mobility

    has_many :taggable_tags, dependent: :restrict_with_exception
    has_many :taggables, through: :taggable_tags

    translates :name, backend: :jsonb
  end
end
