module Spina::Shop
  class DiscountRule < ApplicationRecord
    include Preferable
    
    belongs_to :discount

    def eligible?(order_item)
      true
    end

  end
end

# Necessary for STI and the descendants method
Dir[Spina::Shop::Engine.root.join *%w(app models spina discounts rules *) ].each do |file|
  require_dependency file
end
