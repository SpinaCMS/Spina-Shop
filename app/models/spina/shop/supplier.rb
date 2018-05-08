module Spina::Shop
  class Supplier < ApplicationRecord
    has_many :stock_orders, dependent: :restrict_with_exception

    has_many :products_suppliers, dependent: :destroy
    has_many :products, through: :products_suppliers

    validates :name, presence: true
  end
end