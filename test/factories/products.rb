FactoryBot.define do
  factory :product, class: Spina::Shop::Product do
    name {'Product A'}

    active {true}

    tax_group
    sales_category

    base_price {12.5}

    factory :product_with_stock do
      stock_level {1}

      after(:create) do |product, evaluator|
        create(:stock_level_adjustment, adjustment: evaluator.stock_level, product: product)
        product.save
      end
    end
  end
end
