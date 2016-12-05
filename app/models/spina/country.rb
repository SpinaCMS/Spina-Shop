module Spina
  class Country < ApplicationRecord
    has_many :invoices, dependent: :restrict_with_exception
    has_many :customers, dependent: :restrict_with_exception
    
    validates :iso_3166, presence: true, uniqueness: true
  end
end