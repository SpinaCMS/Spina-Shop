FactoryGirl.define do
  factory :country, class: Spina::Shop::Country do

    factory :the_netherlands do
      name 'The Netherlands'
    end

    factory :belgium do
      name 'Belgium'
    end

    factory :germany do
      name 'Germany'
    end
    
  end
end