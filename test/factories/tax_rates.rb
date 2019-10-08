FactoryBot.define do
  factory :tax_rate, class: Spina::Shop::TaxRate do

    factory :default_tax_rate do
      rate {21}
      code {'4'}
      tax_group
    end

    factory :eu_business_tax_rate do
      rate {0}
      business { true }
      code {'7'}
      tax_group
    end

    factory :germany_tax_rate do
      rate {19}
      code {'13'}
      association :tax_rateable, factory: :germany
      tax_group
    end

    factory :germany_business_tax_rate do
      rate {0}
      business { true }
      code {'7'}
      association :tax_rateable, factory: :germany
      tax_group
    end

    factory :switzerland_tax_rate do
      rate {0}
      code {'6'}
      association :tax_rateable, factory: :switzerland
      tax_group
    end

  end
end
