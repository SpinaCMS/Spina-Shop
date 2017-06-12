FactoryGirl.define do
  factory :product_item, class: Spina::Shop::ProductItem do
    active true

    product
    tax_group
    sales_category

    price BigDecimal.new("12.50")

    factory :product_item_with_stock do
      transient do
        stock_level 1
      end

      after(:create) do |product_item, evaluator|
        create(:stock_level_adjustment, adjustment: evaluator.stock_level, product_item: product_item)
      end
    end
  end
end