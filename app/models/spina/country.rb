module Spina
  class Country < ApplicationRecord
    has_many :invoices, dependent: :restrict_with_exception
    has_many :customers, dependent: :restrict_with_exception
    
    validates :code2, presence: true, uniqueness: true
  end
end