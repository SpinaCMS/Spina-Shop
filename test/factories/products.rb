FactoryGirl.define do
  factory :product, class: Spina::Shop::Product do
    active true

    name 'Product A'
  end
end