module Spina
  class DiscountRule < ApplicationRecord
    include Spina::Preferable
    
    belongs_to :discount

    def eligible?(order_item)
      true
    end

  end
end

require_dependency "#{File.dirname(__FILE__)}/discounts/rules/all_orders"
require_dependency "#{File.dirname(__FILE__)}/discounts/rules/collection"
require_dependency "#{File.dirname(__FILE__)}/discounts/rules/order_total"