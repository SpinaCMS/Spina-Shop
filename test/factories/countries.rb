FactoryGirl.define do
  factory :country, class: Spina::Shop::Country do

    initialize_with { Spina::Shop::Country.where(code: code).first_or_create(name: name) }

    factory :the_netherlands do
      name 'The Netherlands'
      code 'NL'
    end

    factory :germany do
      name 'Germany'
      code 'DE'
    end
    
  end
end