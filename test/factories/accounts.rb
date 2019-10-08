FactoryBot.define do
  factory :account, class: Spina::Account do
    name { 'My Webshop' }
    preferences { { theme: 'default' } }
  end
end
