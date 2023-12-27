module Spina::Shop
  class ProductReturn < ApplicationRecord
    belongs_to :order
    
    # A ProductReturn can contain multiple lines of returned products
    has_many :product_return_items, dependent: :destroy
    
    scope :open, -> { where(closed_at: nil) }
    scope :closed, -> { where.not(closed_at: nil) }
    
    accepts_nested_attributes_for :product_return_items, allow_destroy: true, reject_if: -> (attrs) { attrs['quantity'].to_i == 0 }
    
    # After closing a return, create Stock Level Adjustments
    def close!(actor:)
      self.transaction do
        product_return_items.each do |item|
          next unless item.product.stock_enabled?
          ChangeStockLevel.new(item.product, {
            adjustment: item.returned_quantity,
            description: "Return #{number}",
            # expiration_year: "...",
            # expiration_month: "...",
            actor: actor
          }).save
        end
        
        touch(:closed_at)
      end
    end
    
    # Return number is just the ID with some extra zeroes
    def number
      id.to_s.rjust(8, '0')
    end
    
    def closed?
      closed_at.present?
    end
    
    def open?
      !closed?
    end
    
  end
end
