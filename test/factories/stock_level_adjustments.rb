FactoryGirl.define do
  factory :stock_level_adjustment, class: Spina::Shop::StockLevelAdjustment do
    product_item
    adjustment 1
  end
end