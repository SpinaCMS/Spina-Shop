module Spina
  class CustomerAccount < ApplicationRecord
    has_secure_password
    has_secure_token :password_reset_token
    
    belongs_to :customer

    validates :email, presence: true, uniqueness: true
    # validates :password, length: {minimum: 6, maximum: 40}, on: [:create, :update]

    accepts_nested_attributes_for :customer
  end
end