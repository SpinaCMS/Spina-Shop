module Spina
  module Shop
    class CustomerGroup < ApplicationRecord
      has_many :customers, dependent: :restrict_with_exception

      validates :name, presence: true
    end
  end
end