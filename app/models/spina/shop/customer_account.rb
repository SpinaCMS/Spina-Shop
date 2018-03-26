module Spina::Shop
  class CustomerAccount < ApplicationRecord
    attr_accessor :validate_password

    has_secure_password
    has_secure_token :password_reset_token
    
    belongs_to :customer
    belongs_to :store, optional: true

    validates :email, presence: true, uniqueness: {scope: :store_id}
    validates :password, length: {minimum: 6, maximum: 40}, if: :validate_password

    accepts_nested_attributes_for :customer
  end
end