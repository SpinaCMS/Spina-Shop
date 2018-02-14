module Spina::Shop
  class Store < ApplicationRecord
    validates :name, presence: true
  end
end