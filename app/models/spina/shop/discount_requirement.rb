module Spina::Shop
  class DiscountRequirement < ApplicationRecord
    include Preferable
    
    belongs_to :discount

    def eligible?(order)
      true
    end

  end
end

# Necessary for STI and the descendants method
Dir[Spina::Shop::Engine.root.join *%w(app models spina shop discounts requirements *) ].each do |file|
  require_dependency file
end
