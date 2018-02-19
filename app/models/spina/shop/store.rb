module Spina::Shop
  class Store < ApplicationRecord
    validates :name, presence: true

    has_many :available_products, dependent: :restrict_with_exception
    has_many :products, through: :available_products

    def initials
      name.split(' ').map{|i| i[0]}.join('').upcase
    end
  end
end