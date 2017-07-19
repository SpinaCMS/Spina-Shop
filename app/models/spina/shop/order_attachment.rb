module Spina::Shop
  class OrderAttachment < ApplicationRecord
    belongs_to :order

    attachment :attachment

    validates :name, presence: true
  end
end