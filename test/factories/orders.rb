FactoryBot.define do
  factory :order, class: Spina::Shop::Order do
    # Order stuff
    prices_include_tax {true}
    association :billing_country, factory: :the_netherlands

    factory :order_with_details do
      first_name            {"Bram"}
      last_name             {"Jetten"}
      email                 {"bram@denkgroot.com"}
      billing_street1       {"Keizersgracht"}
      billing_city          {"Amsterdam"}
      billing_postal_code   {"1234 AB"}
      billing_house_number  {"50"}

      factory :order_with_order_items do
        after(:create) do |order, evaluator|
          product = create(:product_with_stock, stock_level: 10)
          create(:order_item, quantity: 1, order: order, orderable: product)
        end

        factory :order_from_germany do
          association :billing_country, factory: :germany
        end

        factory :order_from_france do
          association :billing_country, factory: :france
        end

        factory :business_order_from_germany do
          business {true}
          association :billing_country, factory: :germany
        end

        factory :business_order_from_france do
          business {true}
          association :billing_country, factory: :france
        end

        factory :business_order_from_switzerland do
          business {true}
          association :billing_country, factory: :switzerland
        end
      end
    end

  end
end
