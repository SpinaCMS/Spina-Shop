module Spina
  class CustomerAccount < ApplicationRecord
    has_secure_password
    
    belongs_to :customer

    validates :username, presence: true, uniqueness: true
    validates :password, length: {minimum: 6, maximum: 40}, on: [:create, :update]
  end
end