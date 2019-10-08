FactoryBot.define do
  factory :stock_level_adjustment, class: Spina::Shop::StockLevelAdjustment do
    product
    adjustment {1}
  end
end
