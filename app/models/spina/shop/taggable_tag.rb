module Spina::Shop
  class TaggableTag < ApplicationRecord
    belongs_to :tag
    belongs_to :taggable, polymorphic: true
  end
end