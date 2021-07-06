module Spina::Shop
  class ProductLocation < ApplicationRecord
    belongs_to :product
    belongs_to :location
    belongs_to :location_code
    
    after_save :store_location
    after_destroy :remove_location
    
    private
    
      def store_location
        product.update(location: location_code.code) if location.primary?
      end
      
      def remove_location
        product.update(location: "") if location.primary?
      end
      
  end
end
