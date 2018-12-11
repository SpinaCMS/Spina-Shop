module Spina::Shop
  class CustomerAccount < ApplicationRecord
    attr_accessor :validate_password

    has_secure_password
    has_secure_token :password_reset_token
    has_secure_token :magic_link_token
    
    belongs_to :customer
    belongs_to :store, optional: true

    validates :email, email: true, presence: true, uniqueness: {scope: :store_id}
    validates :password, length: {minimum: 6, maximum: 40}, if: :validate_password

    accepts_nested_attributes_for :customer

    def email=(email)
      email = email.strip if email
      super
    end
  end
end