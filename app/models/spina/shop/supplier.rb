module Spina::Shop
  class Supplier < ApplicationRecord
    has_many :stock_orders, dependent: :restrict_with_exception

    has_many :products, dependent: :nullify

    validates :name, presence: true
  end
end