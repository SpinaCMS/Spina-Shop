module Spina::Shop
  class SharedProperty < ApplicationRecord
    has_many :property_options, as: :property, dependent: :destroy

    accepts_nested_attributes_for :property_options, allow_destroy: true, reject_if: :all_blank
  end
end