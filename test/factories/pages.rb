FactoryBot.define do
  factory :page, class: Spina::Page do
    draft {false}
    active {true}

    factory :homepage do
      name {'homepage'}
      deletable {false}
    end

    factory :products do
      name {'products'}
      deletable {false}
    end

  end
end
