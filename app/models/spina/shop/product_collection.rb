module Spina
  module Shop
    class ProductCollection < ApplicationRecord
      has_many :collectables, dependent: :destroy
      has_many :products, through: :collectables
    end
  end
end