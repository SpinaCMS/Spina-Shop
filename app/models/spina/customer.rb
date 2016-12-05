module Spina
  class Customer < ApplicationRecord
    # Don't destroy Customer if it has orders or invoices
    has_many :orders, dependent: :restrict_with_exception
    has_many :invoices, dependent: :restrict_with_exception

    # Destroy all addresses if you destroy customer
    has_many :addresses, dependent: :destroy
    has_many :product_reviews, dependent: :destroy

    # Destroy the customer account if the customer is also destroyed
    has_one :customer_account, dependent: :destroy

    belongs_to :country

    before_save :set_full_name, if: -> { first_name_changed? || last_name_changed? }
    after_create :set_number

    scope :sorted, -> { order(created_at: :desc) }

    accepts_nested_attributes_for :addresses, allow_destroy: true

    validates :last_name, :email, :country, presence: true#, format: { with: EMAIL_REGEX }

    def name
      company.blank? ? full_name : "#{company} (#{full_name})"
    end

    def ip_addresses
      orders.select("ip_address, count(*) as total_count").group(:ip_address).order("total_count DESC").where.not(ip_address: nil).limit(5).map(&:ip_address)
    end

    def billing_address
      addresses.billing.first
    end

    def delivery_address
      addresses.delivery.first
    end

    private

      def set_full_name
        write_attribute(:full_name, "#{first_name} #{last_name}")
      end

      def set_number
        self.update_column(:number, id + 100000)
      end
  end
end