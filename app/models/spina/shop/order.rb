module Spina::Shop
  class Error < StandardError; end
end

module Spina::Shop
  class Order < ApplicationRecord
    require_dependency 'spina/shop/order/state_machine_transitions'
    require_dependency 'spina/shop/order/billing'

    has_secure_token

    attr_accessor :validate_details, :validate_stock, :validate_delivery, :validate_payment, :password

    belongs_to :customer, optional: true
    belongs_to :billing_country, class_name: "Spina::Shop::Country"
    belongs_to :delivery_country, class_name: "Spina::Shop::Country", optional: true
    belongs_to :delivery_option, optional: true
    belongs_to :duplicate, class_name: "Spina::Shop::Order", optional: true

    has_many :order_transitions, autosave: false, dependent: :destroy
    has_many :order_items, dependent: :destroy # Destroy order items if the order is destroyed as well
    has_many :invoices, dependent: :restrict_with_exception
    has_many :order_attachments, dependent: :destroy
    has_one :shop_review, dependent: :destroy

    has_one :discounts_order, class_name: "Spina::Shop::DiscountsOrder"
    has_one :discount, through: :discounts_order, class_name: "Spina::Shop::Discount"
    has_one :gift_cards_order, class_name: "Spina::Shop::GiftCardsOrder"
    has_one :gift_card, through: :gift_cards_order, class_name: "Spina::Shop::GiftCard"

    scope :sorted, -> { order(order_number: :desc, id: :desc) }
    scope :received, -> { where.not(received_at: nil) }
    scope :prepared, -> { where.not(order_prepared_at: nil) }
    scope :confirmed, -> { where.not(confirming_at: nil) }
    scope :shipped, -> { where.not(shipped_at: nil) }
    scope :paid, -> { where.not(paid_at: nil) }
    scope :building, -> { in_state(:building) }

    # Always validate
    validates :password, confirmation: true
    validates :password, length: {minimum: 6, maximum: 40}, allow_blank: true

    # Validate when after checkout phase
    validates :order_number, presence: true, uniqueness: true, unless: -> { in_state?(:building) }

    # Validate details
    validates :first_name, :last_name, :email, :billing_street1, :billing_city, :billing_postal_code, :billing_country_id, presence: true, if: -> { validate_details }
    validates :delivery_name, :delivery_street1, :delivery_city, :delivery_postal_code, presence: true, if: -> { validate_details && separate_delivery_address? }
    validates :email, email: true, if: -> { validate_details }
    validate :must_be_of_age_to_buy_products, if: -> { validate_details }

    # Validate delivery
    validates :delivery_option, presence: true, if: -> { validate_delivery }

    # Validate payment
    validates :payment_method, presence: true, if: -> { validate_payment }

    # Validate Stock
    validate :items_must_be_in_stock, if: -> { validate_stock }
    validate :must_have_at_least_one_item, if: -> { validate_stock }
    before_validation :validate_stock_for_order_items, if: -> { validate_stock }

    accepts_nested_attributes_for :order_items

    # Override addresses if necessary
    [:delivery_name, :delivery_street1, :delivery_postal_code, :delivery_city, :delivery_house_number, :delivery_house_number_addition, :delivery_country].each do |f|
      define_method(f) do
        separate_delivery_address? ? super() : send(f.to_s.gsub('delivery_', 'billing_'))
      end
    end

    def billing_address
      "#{billing_street1} #{billing_house_number} #{billing_house_number_addition}".strip
    end

    def delivery_address
      "#{delivery_street1} #{delivery_house_number} #{delivery_house_number_addition}".strip
    end

    def assign_address(address, address_type:)
      [:street1, :postal_code, :city, :house_number, :house_number_addition, :country].each do |f|
        send("#{address_type}_#{f}=", address.send(f))
      end
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

    def products
      order_items.map do |order_item|
        if order_item.is_product_bundle?
          order_item.orderable.products
        else
          order_item.orderable
        end
      end.flatten.uniq
    end

    def first_order_for_email?
      self.class.where('lower(email) = ?', email&.downcase).paid.order(:paid_at).first.try(:id) == id
    end

    # By default this method returns false, but you can override it and add your own logic
    def vat_reverse_charge?
      false
    end

    # If VAT is reverse charged, all prices must be excluding VAT
    def prices_include_tax
      vat_reverse_charge? ? false : read_attribute(:prices_include_tax)
    end

    # Order number with zeroes
    def number
      order_number ? order_number.to_s.rjust(8, '0') : nil
    end

    def billing_name
      full_name = "#{first_name} #{last_name}".strip
      company.present? ? "#{company} (#{full_name})" : full_name
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

    def apply_gift_card!
      transaction do
        update_attributes!(gift_card_amount: gift_card_amount)
        gift_card.update_attributes!(remaining_balance: gift_card.remaining_balance - gift_card_amount)
      end
    end

    def remove_gift_card!
      transaction do
        gift_card.update_attributes!(remaining_balance: gift_card.remaining_balance + gift_card_amount)
        update_attributes!(gift_card_amount: nil)
      end
    end

    def remove_discount!
      update_attributes!(discount: nil)
    end

    def duplicate!
      # Duplicate order
      transaction do
        shopping_cart = Order.create!(attributes.reject{|key, value| key.in? %w(id delivery_price delivery_tax_rate status received_at shipped_at paid_at delivered_at order_prepared_at payment_id payment_url payment_failed failed_at  cancelled_at delivery_tracking_ids picked_up_at order_number confirming_at created_at updated_at)})
        shopping_cart.discount = discount
        shopping_cart.gift_card = gift_card
        order_items.roots.each do |order_item|
          new_item = OrderItem.create!(order_item.attributes.reject{|key, value| key.in? %w(id created_at updated_at unit_price unit_cost_price discount_amount weight tax_rate order_id)}.merge(order_id: shopping_cart.id))

          # Duplicate children
          order_item.children.each do |child|
            new_item.children.create!(child.attributes.reject{|key, value| key.in? %w(id created_at updated_at unit_price unit_cost_price discount_amount weight tax_rate order_id)}.merge(order_id: shopping_cart.id))
          end
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

      def items_must_be_in_stock
        errors.add(:base, :stock_level_not_sufficient) unless order_items.all?(&:in_stock?)
      end

      def validate_stock_for_order_items
        order_items.each{ |i| i.validate_stock = true }
      end

      def must_have_at_least_one_item
        errors.add(:base, :shopping_cart_empty) if order_items.none?
      end

      def must_be_of_age_to_buy_products
        if order_items.any?{|item| item.orderable.must_be_of_age_to_buy?}
          errors.add(:date_of_birth, :not_of_age) unless of_age?
        end
      end

  end
end