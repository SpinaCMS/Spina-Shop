FactoryGirl.define do
  factory :product, class: Spina::Shop::Product do
    name 'Product A'

    active true

    tax_group
    sales_category

    price BigDecimal.new("12.50")

    factory :product_with_stock do
      stock_level 1

      after(:create) do |product, evaluator|
        create(:stock_level_adjustment, adjustment: evaluator.stock_level, product: product)
        product.save
      end
    end
  end
end