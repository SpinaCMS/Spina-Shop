module Spina::Shop
  class DiscountAction < ApplicationRecord
    include Preferable

    belongs_to :discount

    # Default discount is 0
    def compute(order_item)
      BigDecimal(0)
    end
  end
end

# Necessary for STI and the descendants method
Dir[Spina::Shop::Engine.root.join *%w(app models spina shop discounts actions *) ].each do |file|
  require_dependency file
end