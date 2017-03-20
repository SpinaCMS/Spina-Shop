module Spina
  class DiscountAction < ApplicationRecord
    include Spina::Preferable

    belongs_to :discount

    def compute(order_item)
      true
    end

    def self.discount_action_classes
      if descendants.empty?
        Dir["#{Spina::Shop::Engine.root}/app/models/spina/discounts/actions/*.rb"].each do |file|
          require_dependency file
        end
      end

      base_class.descendants
    end
  end
end