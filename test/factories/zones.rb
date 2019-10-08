FactoryBot.define do
  factory :zone, class: Spina::Shop::Zone do

    initialize_with { Spina::Shop::Zone.where(code: code).first_or_create(name: name) }

    factory :eu do
      name {'EU'}
      code {'EU'}
    end
    
  end
end
