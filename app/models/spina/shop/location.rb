module Spina::Shop
  class Location < ApplicationRecord
    # belongs_to :storage_location
    # belongs_to :location, optional: true
    
    # has_many :locations, dependent: :restrict_with_exception
    
    has_many :product_locations, dependent: :restrict_with_exception
    has_many :products, through: :product_locations
  end
end
