module Spina::Shop
  class ProductItem < ApplicationRecord
    belongs_to :product, inverse_of: :product_items
    belongs_to :tax_group
    belongs_to :sales_category

    has_many :order_items, as: :orderable, dependent: :restrict_with_exception
    has_many :bundled_product_items, dependent: :restrict_with_exception
    has_many :product_bundles, through: :bundled_product_items, dependent: :restrict_with_exception
    has_many :stock_level_adjustments, dependent: :destroy
    has_many :in_stock_reminders, as: :orderable, dependent: :destroy

    # Active items
    scope :active, -> { where(active: true) }

    # Cache product averages
    #before_save :cache_averages
    #after_save :cache_product_averages

    validates :price, presence: true

    # Get the price based on the one ordering. Can be different based on customer groups.
    def price_for_customer(customer)
      price
    #   return price if customer.nil?
    #   # price_exceptions.find_by!(exceptionable: [customer, customer.customer_group]).price
    #   price
    # rescue ActiveRecord::RecordNotFound
    #   price
    end

    # Short description is description and description is the 
    # Product's name and ProductItem's name combined. Like wtf.
    def short_description
      description
    end

    def description
      [product.name, name].compact.join(', ')
    end

    def product_images
      product.product_images
    end

    def weight
      read_attribute(:weight) || BigDecimal(0)
    end

    def in_stock?
      stock_level > 0
    end

    def active?
      active?
    end

    def inactive?
      !active
    end

    def cache_everything
      cache_averages
    end

    private

      def cache_averages
        write_attribute :stock_level, stock_level_adjustments.sum(:adjustment)
        write_attribute :expiration_date, can_expire? ? earliest_expiration_date : nil
      end

      # Earliest expiration date is calculated by the order of stock level adjustments
      # The order of stock level adjustments is purely based on the created_at column
      # Can be nil if a ProductItem previously couldn't expire
      # 
      # Currently only in mm/yy format. First day of the month.
      def earliest_expiration_date
        offset = 0
        sum = 0
        adjustment = stock_level_adjustments.ordered.additions.offset(offset).first
        while sum < stock_level do
          adjustment = stock_level_adjustments.ordered.additions.offset(offset).first
          offset = offset.next
          sum = sum + adjustment.try(:adjustment).to_i
        end 

        if adjustment.try(:expiration_year).present?
          Date.new.change(day: 1, month: adjustment.expiration_month || 1, year: adjustment.expiration_year)
        else
          nil
        end
      end

      def cache_product_averages
        product.save
      end
  end
end