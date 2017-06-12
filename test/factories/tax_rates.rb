FactoryGirl.define do
  factory :tax_rate, class: Spina::Shop::TaxRate do

    factory :default_tax_rate do
      rate BigDecimal.new(21)
      code '21'
      tax_group
    end

  end
end