FactoryGirl.define do
  factory :tax_rate, class: Spina::Shop::TaxRate do

    factory :default_tax_rate do
      rate 21
      code '21'
      tax_group
    end

    factory :german_tax_rate do
      rate 19
      code '19'
      association :tax_rateable, factory: :germany
      tax_group
    end

    factory :german_business_tax_rate do
      rate 0
      code '999'
      business true
      association :tax_rateable, factory: :germany
      tax_group
    end

    factory :france_business_tax_rate do
      rate 0
      code '9998'
      business true
      association :tax_rateable, factory: :france
      tax_group
    end

  end
end