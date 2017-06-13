FactoryGirl.define do
  factory :tax_rate, class: Spina::Shop::TaxRate do

    factory :default_tax_rate do
      rate BigDecimal.new(21)
      code '21'
      tax_group
    end

    factory :german_tax_rate do
      rate BigDecimal.new(19)
      code '19'
      association :tax_rateable, factory: :germany
      tax_group
    end

  end
end