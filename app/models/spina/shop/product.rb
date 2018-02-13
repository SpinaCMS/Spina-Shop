module Spina::Shop
  class Product < ApplicationRecord
    # Stores the old path when generating a new materialized_path
    attr_accessor :old_path

    belongs_to :tax_group
    belongs_to :sales_category
    belongs_to :product_category, optional: true

    has_many :product_images, dependent: :destroy
    has_many :product_reviews, dependent: :destroy
    has_many :product_relations, dependent: :destroy
    has_many :related_products, through: :product_relations
    has_many :favorites, dependent: :destroy
    has_many :collectables, dependent: :destroy
    has_many :product_collections, through: :collectables

    belongs_to :parent, class_name: "Product", optional: true
    has_many :children, class_name: "Product", foreign_key: :parent_id, dependent: :nullify

    has_many :order_items, as: :orderable, dependent: :restrict_with_exception
    has_many :stock_level_adjustments, dependent: :destroy
    has_many :in_stock_reminders, as: :orderable, dependent: :destroy

    has_many :bundled_products, dependent: :restrict_with_exception

    accepts_nested_attributes_for :product_images, allow_destroy: true
    accepts_attachments_for :product_images, append: true

    # Generate materialized path
    before_validation :set_name, if: :variant?
    before_validation :set_variant_name
    before_validation :set_materialized_path
    before_validation :set_parent_product_properties, if: :variant?

    # Create a 301 redirect if materialized_path changed
    after_save :rewrite_rule
    after_save :save_children, if: :has_children?

    validates :name, :base_price, presence: true
    validates :sku, uniqueness: true, allow_blank: true

    # Mobility translates
    translates :name, :variant_name, :description, :materialized_path
    translates :seo_title, default: -> { name }
    translates :seo_description, default: -> { description }

    # Active product
    scope :active, -> { where(active: true, archived: false) }

    # Postgres-specific queries for the jsonb column
    scope :where_any_tags, -> (key, value) do
      value = [value] unless value.kind_of?(Array)
      value = value.map{|v| Product.connection.quote_string(v)}
      where("spina_shop_products.properties->'#{key}' ?| array['#{value.join('\',\'')}']")
    end

    scope :where_all_tags, -> (key, value) do
      value = [value] unless value.kind_of?(Array)
      value = value.map{|v| Product.connection.quote_string(v)}
      where("spina_shop_products.properties->'#{key}' ?& array['#{value.join('\',\'')}']")
    end

    scope :where_in_range, -> (key, min, max) { where("CAST(coalesce(NULLIF(REPLACE(spina_shop_products.properties->>'#{key}', ',', '.'), ''), '0') AS numeric) BETWEEN ? AND ?", min, max) }

    def to_s
      name
    end

    def full_name
      [name, variant_name].compact.join(' / ')
    end

    def variant?
      parent_id.present?
    end

    def has_children?
      children.any?
    end

    def has_variants?
      variant? || children.any?
    end

    def variants
      (parent || self).children.to_a.unshift(parent || self)
    end

    def can_have_variants?
      !variant?
    end

    def promotion?
      promotional_price.present?
    end

    def price
      promotional_price.presence || base_price
    end

    def price_for_order(order)
      # Return the default price if we don't know anything about the order
      return price if order.nil? 

      # If no conversion is needed, simply return price
      price = price_for_customer(order.customer)
      price_includes_tax = price_includes_tax_for_customer(order.customer)
      return price if price_includes_tax == order.prices_include_tax

      # Price modifier for unit price
      price_modifier = tax_group.price_modifier_for_order(order)

      # Calculate unit price based on price modifier
      unit_price = price_includes_tax ? price / price_modifier : price * price_modifier

      # Round to two decimals using bankers' rounding
      return unit_price.round(2, :half_even)
    end

    def price_for_customer(customer)
      return price if customer.nil?
      price_exception_for_customer(customer).try(:[], 'price').try(:to_d) || price
    end

    def price_includes_tax_for_customer(customer)
      return price_includes_tax if customer.nil?
      price_exception = price_exception_for_customer(customer)
      if price_exception.present?
        ActiveRecord::Type::Boolean.new.cast(price_exception['price_includes_tax'])
      else
        price_includes_tax
      end
    end

    def in_stock?
      return true unless stock_enabled?
      stock_level > 0
    end

    # All properties are dynamically stored using jsonb
    def properties
      decorate_with_methods(read_attribute(:properties))
    end

    # Get products by filtering their properties
    # Based on querying the jsonb column using Postgres
    def self.filtered(filters, hide_variants: true)
      products = all

      filters ||= []
      filters.each do |filter|
        case filter[:field_type]
        when "select"
          products = products.where_any_tags(filter[:property], filter[:value])
        when "percentage", "decimal", "number"
          if filter[:value]["min"].present? && filter[:value]["max"].present?
            products = products.where_in_range(filter[:property], filter[:value]["min"].presence.try(:to_d) || 0, filter[:value]["max"].presence.try(:to_d) || 0)
          end
        when "price"
          min = filter[:value]["min"].presence.try(:to_d) || 0
          max = filter[:value]["max"].presence.try(:to_d) || 0
          products = products.where("CASE WHEN promotional_price IS NOT NULL THEN promotional_price BETWEEN :min AND :max ELSE base_price BETWEEN :min AND :max END", min: min, max: max)
        end
      end

      return hide_variants ? all.where(parent_id: nil, id: products.pluck("CASE WHEN parent_id IS NULL THEN id ELSE parent_id END")) : products
    end

    def cache_stock_level
      update_columns(
        stock_level: stock_level_adjustments.sum(:adjustment), 
        sales_count: stock_level_adjustments.sales.sum(:adjustment) * -1,
        expiration_date: can_expire? ? earliest_expiration_date : nil
      )
    end

    def earliest_expiration_date
      offset = 0
      sum = 0
      adjustment = stock_level_adjustments.ordered.additions.offset(offset).first
      while sum < stock_level && adjustment.present? do
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

    private

      def set_name
        self.name = parent.name
      end

      def set_variant_name
        self.variant_name = properties.map do |property, value|
          properties.send(property).try(:label)
        end.try(:join, ' - ')
      end

      def save_children
        children.each(&:save)
      end

      def set_parent_product_properties
        assign_attributes(name: parent.name, product_category: parent.product_category)
      end

      def rewrite_rule
        Spina::RewriteRule.where(old_path: old_path).first_or_create.update_attributes(new_path: materialized_path) if old_path != materialized_path
      end

      # Get price exception based on Customer / CustomerGroup if available
      def price_exception_for_customer(customer)
        price_exceptions.try(:[], 'customer_groups').try(:find) do |h|
          h["customer_group_id"].to_i == customer.customer_group_id
        end
      end

      # Get all values for properties defined on the ProductCategory.
      # Defines singleton methods on the properties attribute for this product.
      def decorate_with_methods(jsonb)
        return nil unless product_category.present?
        product_category.properties.each do |property|
          jsonb.define_singleton_method(property.name) do
            case property.field_type
            when 'select'
              if jsonb[property.name].is_a? Array
                jsonb[property.name].map do |option|
                  property.property_options.where(name: option).first
                end.compact
              else
                property.property_options.where(name: jsonb[property.name]).first
              end
            else
              jsonb[property.name]
            end
          end
        end
        jsonb
      end

      # Each product has a unique materialized path which can be used in URL's
      # Actually more like a slug than a path
      # TODO: rename materialized_path to slug
      def set_materialized_path
        self.old_path = materialized_path
        self.materialized_path = localized_materialized_path
        self.materialized_path += "-#{self.class.i18n.where(materialized_path: materialized_path).count}" if self.class.i18n.where(materialized_path: materialized_path).where.not(id: id).count > 0
        materialized_path
      end

      def localized_materialized_path
        if I18n.locale == I18n.default_locale
          full_name.try(:parameterize).prepend('/products/')
        else
          full_name.try(:parameterize).prepend("/#{I18n.locale}/products/").gsub(/\/\z/, "")
        end
      end

  end
end
