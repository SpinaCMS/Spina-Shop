module Spina::Shop
  class Country < Zone
    has_many :customers, dependent: :restrict_with_exception
  end
end