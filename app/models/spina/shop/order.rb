module Spina::Shop
  class Error < StandardError; end
end

module Spina::Shop
  class Order < ApplicationRecord
    include PgSearch

    require_dependency 'spina/shop/order/state_machine_transitions'
    require_dependency 'spina/shop/order/billing'

    has_secure_token

    attr_accessor :validate_details, :validate_stock, :validate_delivery, :validate_payment, :password

    belongs_to :customer, optional: true
    belongs_to :billing_country, class_name: "Spina::Shop::Country"
    belongs_to :delivery_country, class_name: "Spina::Shop::Country", optional: true
    belongs_to :delivery_option, optional: true
    belongs_to :duplicate, class_name: "Spina::Shop::Order", optional: true
    belongs_to :store, optional: true

    has_many :order_transitions, autosave: false, dependent: :destroy
    has_many :order_items, dependent: :destroy # Destroy order items if the order is destroyed as well
    has_many :invoices, dependent: :restrict_with_exception
    has_many :order_attachments, dependent: :destroy
    has_one :shop_review, dependent: :destroy

    # Duplicate orders
    has_one :original_order, class_name: "Spina::Shop::Order", foreign_key: :duplicate_id

    has_one :discounts_order, class_name: "Spina::Shop::DiscountsOrder"
    has_one :discount, through: :discounts_order, class_name: "Spina::Shop::Discount"
    has_many :gift_cards_orders, class_name: "Spina::Shop::GiftCardsOrder"
    has_many :gift_cards, through: :gift_cards_orders, class_name: "Spina::Shop::GiftCard"

    scope :sorted, -> { order(order_number: :desc) }
    scope :received, -> { where.not(received_at: nil) }
    scope :prepared, -> { where.not(order_prepared_at: nil) }
    scope :confirmed, -> { where.not(confirming_at: nil) }
    scope :shipped, -> { where.not(shipped_at: nil) }
    scope :paid, -> { where.not(paid_at: nil) }
    scope :building, -> { in_state(:building) }
    scope :refunded, -> { where.not(refunded_at: nil) }
    scope :concept, -> { building.where(manual_entry: true) }
    scope :to_process, -> { received.where(cancelled_at: nil, failed_at: nil, shipped_at: nil, picked_up_at: nil, refunded_at: nil, ready_for_pickup_at: nil).where("paid_at IS NOT NULL OR payment_method = 'postpay'") }

    # Always validate
    validates :password, confirmation: true
    validates :password, length: {minimum: 6, maximum: 40}, allow_blank: true

    # Validate when after checkout phase
    validates :order_number, presence: true, uniqueness: true, unless: -> { in_state?(:building) }

    # Validate details
    validates :first_name, :last_name, :email, :billing_street1, :billing_city, :billing_postal_code, :billing_country_id, presence: true, if: -> { validate_details }
    validates :delivery_street1, :delivery_city, :delivery_postal_code, presence: true, if: -> { validate_details && separate_delivery_address? }
    validates :email, email: true, if: -> { validate_details }
    validate :must_be_of_age_to_buy_products, if: -> { validate_details }
    validate :must_have_any_delivery_name, if: -> { validate_details && separate_delivery_address? }

    # Validate delivery
    validates :delivery_option, presence: true, if: -> { validate_delivery }

    # Validate payment
    validates :payment_method, presence: true, if: -> { validate_payment }

    # Validate Stock
    validate :items_must_be_in_stock, if: -> { validate_stock }
    validate :must_have_at_least_one_item, if: -> { validate_stock }
    validate :items_must_be_below_limit, if: -> { validate_stock }
    before_validation :validate_stock_for_order_items, if: -> { validate_stock }

    accepts_nested_attributes_for :order_items

    # Search
    pg_search_scope :search, 
        against: [:order_number, :first_name, :last_name, :company, :email, :delivery_city, :billing_city, :received_at], 
        associated_against: {
          delivery_option: [:name],
          customer: [:full_name]
        },
        using: {
          tsearch: {prefix: true}
        },
        order_within_rank: "order_number DESC, id DESC"

    # Override addresses if necessary
    [:delivery_name, :delivery_street1, :delivery_postal_code, :delivery_city, :delivery_house_number, :delivery_house_number_addition, :delivery_country].each do |f|
      define_method(f) do
        separate_delivery_address? ? super() : send(f.to_s.gsub('delivery_', 'billing_'))
      end
    end

    [:delivery_full_name, :delivery_first_name, :delivery_last_name, :delivery_company].each do |f|
      define_method(f) do
        separate_delivery_address? ? super() : send(f.to_s.gsub('delivery_', ''))
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

    def payment_methods
      Spina::Shop.config.payment_methods
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
      order_items.map(&:products).flatten.uniq
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

    def delivery_full_name
      "#{delivery_first_name} #{delivery_last_name}".strip
    end

    def delivery_name
      return read_attribute(:delivery_name) if read_attribute(:delivery_name).present?
      delivery_company.present? ? "#{delivery_company} (#{delivery_full_name})" : delivery_full_name
    end

    def full_name
      "#{first_name} #{last_name}".strip
    end

    def billing_name
      company.present? ? "#{company} (#{full_name})" : full_name
    end

    def total_items
      order_items.sum(:quantity)
    end
    
    def total_product_items
      order_items.products.sum(:quantity) + order_items.product_bundles.joins("INNER JOIN spina_shop_product_bundles ON spina_shop_product_bundles.id = spina_shop_order_items.orderable_id INNER JOIN spina_shop_bundled_products ON spina_shop_bundled_products.product_bundle_id = spina_shop_product_bundles.id").sum("spina_shop_bundled_products.quantity * spina_shop_order_items.quantity")
    end

    def total_weight
      order_items.inject(BigDecimal(0)) { |t, i| t + i.total_weight }
    end

    def total_weight_in_ounces
      Measurement.parse("#{total_weight} gr").convert_to(:oz).quantity
    end

    def merge!(order)
      raise Error if confirmed? || order.confirmed?
      return if order == self # Can't merge with itself, that would destroy all order items

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
      date_of_birth&.year.to_i > 1900 && (age >= 18 if age)
    end

    def remove_discount!
      update!(discount: nil)
    end

    # This should be reversed
    # Duplicating an order not by rejecting attributes, but by whitelisting attributes
    def duplicate!
      # Duplicate order
      transaction do
        shopping_cart = Order.create!(attributes.reject{|key, value| key.in? %w(id delivery_price delivery_tax_rate status received_at shipped_at paid_at delivered_at order_prepared_at payment_id payment_url payment_failed failed_at  cancelled_at delivery_tracking_ids picked_up_at order_number confirming_at created_at updated_at token gift_card_amount total_cash rounding_difference ga_client_id payment_reminder_sent_at refunded_at refund_method refund_reason)})
        shopping_cart.discount = discount
        shopping_cart.gift_cards = gift_cards
        order_items.roots.each do |order_item|
          new_item = OrderItem.create!(order_item.attributes.reject{|key, value| key.in? %w(id created_at updated_at unit_price unit_cost_price discount_amount weight tax_rate order_id)}.merge(order_id: shopping_cart.id))

          # Duplicate children
          order_item.children.each do |child|
            new_item.children.create!(child.attributes.reject{|key, value| key.in? %w(id created_at updated_at unit_price unit_cost_price discount_amount weight tax_rate order_id)}.merge(order_id: shopping_cart.id))
          end
        end
        update!(duplicate: shopping_cart)
      end
    end

    def everything_valid?
      self.validate_details = true
      self.validate_stock = true
      self.validate_payment = true
      self.validate_delivery = true
      valid?
    end
    
    def order_pick_list
      OrderPickList.new(self)
    end

    private

      def items_must_be_in_stock
        errors.add(:base, :stock_level_not_sufficient) unless order_items.all?(&:in_stock?)
      end

      def items_must_be_below_limit
        errors.add(:base, :item_limit_exceeded) unless order_items.all?(&:below_limit?)
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

      def must_have_any_delivery_name
        errors.add(:delivery_last_name, :blank) if delivery_name.blank?
      end

  end
end