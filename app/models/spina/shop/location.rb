module Spina::Shop
  class Location < ApplicationRecord    
    has_many :product_locations, dependent: :restrict_with_exception
    has_many :products, through: :product_locations
    
    has_many :location_codes, dependent: :restrict_with_exception
  end
end
