module Spina
  class CustomerAccount < ApplicationRecord
    has_secure_password
    
    belongs_to :customer

    validates :username, presence: true, uniqueness: true
  end
end