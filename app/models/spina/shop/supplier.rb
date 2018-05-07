module Spina::Shop
  class Supplier < ApplicationRecord
    has_many :supply_orders, dependent: :restrict_with_exception

    validates :name, presence: true
  end
end