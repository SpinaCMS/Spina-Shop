FactoryGirl.define do
  factory :tax_group, class: Spina::Shop::TaxGroup do
    name 'Default tax'

    after(:create) do |tax_group, evaluator|
      create(:default_tax_rate, tax_group: tax_group)
      create(:german_tax_rate, tax_group: tax_group)
      create(:france_business_tax_rate, tax_group: tax_group)
    end
  end
end