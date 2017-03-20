module Spina
  class DiscountAction < ApplicationRecord
    include Spina::Preferable

    belongs_to :discount

    def compute(order_item)
      true
    end
  end
end

# Necessary for STI and the descendants method
Dir[Spina::Shop::Engine.root.join *%w(app models spina discounts actions *) ].each do |file|
  require_dependency file
end