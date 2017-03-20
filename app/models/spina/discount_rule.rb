module Spina
  class DiscountRule < ApplicationRecord
    include Spina::Preferable
    
    belongs_to :discount

    def eligible?(order_item)
      true
    end
    
    def self.discount_rule_classes
      if descendants.empty?
        Dir["#{Spina::Shop::Engine.root}/app/models/spina/discounts/rules/*.rb"].each do |file|
          require_dependency file
        end
      end

      base_class.descendants
    end

  end
end

