module Spina
  class Error < StandardError; end
end

module Spina
  class Order < ApplicationRecord
    require_dependency 'spina/order/state_machine_transitions'
    require_dependency 'spina/order/billing'

    attr_accessor :validate_details, :validate_stock, :validate_delivery, :validate_payment

    belongs_to :customer, optional: true
    belongs_to :billing_country, class_name: "Spina::Country"
    belongs_to :delivery_country, class_name: "Spina::Country"
    belongs_to :delivery_option, optional: true
    belongs_to :duplicate, class_name: "Spina::Order", optional: true

    has_many :order_transitions, autosave: false, dependent: :destroy
    has_many :order_items, dependent: :destroy # Destroy order items if the order is destroyed as well
    has_many :invoices, dependent: :restrict_with_exception

    has_one :discounts_order, class_name: "Spina::DiscountsOrder"
    has_one :discount, through: :discounts_order, class_name: "Spina::Discount"

    scope :sorted, -> { order(order_number: :desc, id: :desc) }
    scope :received, -> { where.not(received_at: nil) }
    scope :confirmed, -> { where.not(confirming_at: nil) }
    scope :building, -> { in_state(:building) }

    validates :first_name, :last_name, :email, :billing_street1, :billing_city, :billing_postal_code, :billing_house_number, presence: true, if: -> { validate_details }
    validates :delivery_name, :delivery_street1, :delivery_city, :delivery_postal_code, :delivery_house_number, presence: true, if: -> { validate_details && separate_delivery_address? }
    validates :password, confirmation: true
    validates :password, length: {minimum: 6, maximum: 40}, allow_blank: true
    validates :delivery_option, presence: true, if: -> { validate_delivery }
    validates :payment_method, presence: true, if: -> { validate_payment }
    validates :email, email: true, if: -> { validate_details }
    validate :billing_country_must_be_the_same_as_customer, if: -> { validate_details }
    validate :must_be_of_age_to_buy_products, if: -> { validate_details }
    validate :items_must_be_in_stock, if: -> { validate_stock }
    validate :must_have_at_least_one_item, if: -> { validate_stock }
    validates :order_number, presence: true, uniqueness: true, unless: -> { in_state?(:building) }

    accepts_nested_attributes_for :order_items

    # Override addresses if necessary
    [:delivery_name, :delivery_street1, :delivery_postal_code, :delivery_city, :delivery_country, :delivery_house_number, :delivery_house_number_addition].each do |f|
      define_method(f) do
        separate_delivery_address? ? super() : send(f.to_s.gsub('delivery_', 'billing_'))
      end
    end

    def billing_address
      "#{billing_street1} #{billing_house_number}#{billing_house_number_addition}".strip
    end

    def delivery_address
      "#{delivery_street1} #{delivery_house_number}#{delivery_house_number_addition}".strip
    end

    def delivery_options
      DeliveryOption.all
    end

    def soonest_delivery_date
      delivery_option.try(:soonest_delivery_date_for_order, self)
    end

    def empty?
      order_items.none?
    end

    def requires_shipping?
      delivery_option.try(:requires_shipping)
    end

    # Order number with zeroes
    def number
      order_number ? order_number.to_s.rjust(8, '0') : nil
    end

    def billing_name
      "#{first_name} #{last_name}".strip + (company.present? ? "(#{company})" : "")
    end

    def total_items
      order_items.sum(:quantity)
    end

    def total_weight
      order_items.inject(BigDecimal(0)) { |t, i| t + i.total_weight }
    end

    def total_weight_in_ounces
      Measurement.parse("#{total_weight} gr").convert_to(:oz).quantity
    end

    def merge!(order)
      raise Error if confirmed? || order.confirmed?

      transaction do
        order.order_items.where(orderable: order_items.map(&:orderable)).each do |duplicate|
          current_order_item = order_items.find_by(orderable: duplicate.orderable)
          current_order_item.increment(:quantity, duplicate.quantity)
          current_order_item.save
        end

        order.order_items.where(orderable: order_items.map(&:orderable)).destroy_all
        order.order_items.update_all(order_id: id)
      end
    end

    def age
      now = Time.zone.now
      if date_of_birth
        now.year - date_of_birth.year - ((now.month > date_of_birth.month || (now.month == date_of_birth.month && now.day >= date_of_birth.day)) ? 0 : 1)
      end
    end

    def of_age?
      age >= 18 if age
    end

    def cache_delivery_option!
      cache_delivery_option
      save!
    end

    def duplicate!
      # Duplicate order
      transaction do
        shopping_cart = Spina::Order.create!(attributes.reject{|key, value| key.in? %w(id delivery_price delivery_tax_rate status received_at shipped_at paid_at delivered_at order_picked_at payment_id payment_url failed_at cancelled_at delivery_tracking_ids picked_up_at order_number confirming_at created_at updated_at)})
        order_items.each do |order_item|
          OrderItem.create!(order_item.attributes.reject{|key, value| key.in? %w(id created_at updated_at unit_price unit_cost_price weight tax_rate order_id)}.merge(order_id: shopping_cart.id))
        end
        update_attributes!(duplicate: shopping_cart)
      end
    end

    def everything_valid?
      self.validate_details = true
      self.validate_stock = true
      self.validate_payment = true
      self.validate_delivery = true
      valid?
    end

    private

      def cache_delivery_option
        write_attribute :delivery_price, delivery_price
        write_attribute :delivery_tax_rate, delivery_tax_rate
        write_attribute :delivery_metadata, {
          tax_code: delivery_option.tax_group.tax_code_for_order(self),
          sales_category_code: delivery_option.sales_category.code_for_order(self)
        }
      end

      def items_must_be_in_stock
        errors.add(:stock_level, "not sufficient") unless order_items.all?(&:in_stock?)
      end

      def must_have_at_least_one_item
        if order_items.none?
          errors.add(:shopping_cart, "empty")
        end
      end

      def must_be_of_age_to_buy_products
        if order_items.any?{|item| item.orderable.must_be_of_age_to_buy?}
          errors.add(:date_of_birth, "not of age") unless of_age?
        end
      end

      def billing_country_must_be_the_same_as_customer
        if customer.present? && customer.country != billing_country
          errors.add(:billing_country, "not allowed")
        end
      end

  end
end