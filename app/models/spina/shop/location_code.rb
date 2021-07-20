module Spina::Shop
  class LocationCode < ApplicationRecord
    belongs_to :location

    has_many :product_locations    
    has_many :products, through: :product_locations
    
    validates :code, presence: true, uniqueness: {scope: :location_id}
    
    def to_s
      code
    end
  end
end
