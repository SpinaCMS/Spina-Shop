FactoryGirl.define do
  factory :country, class: Spina::Shop::Country do

    initialize_with { Spina::Shop::Country.where(name: name).first_or_create }

    factory :the_netherlands do
      name 'The Netherlands'
    end

    factory :germany do
      name 'Germany'
    end
    
  end
end