FactoryBot.define do
  factory :country, class: Spina::Shop::Country do

    initialize_with { Spina::Shop::Country.where(code: code).first_or_create(name: name) }

    factory :the_netherlands do
      name { 'The Netherlands' }
      code { 'NL' }
      association :parent, factory: :eu
    end

    factory :germany do
      name { 'Germany' }
      code {'DE'}
      association :parent, factory: :eu
    end

    factory :france do
      name { 'France' }
      code {'FR'}
      association :parent, factory: :eu
    end

    factory :switzerland do
      name { "Switzerland" }
      code { "CH" }
    end
    
  end
end
