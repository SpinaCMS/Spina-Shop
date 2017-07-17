module Spina::Shop
  class Product < ApplicationRecord
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

    has_many :order_items, as: :orderable, dependent: :restrict_with_exception
    has_many :stock_level_adjustments, dependent: :destroy
    has_many :in_stock_reminders, as: :orderable, dependent: :destroy

    accepts_nested_attributes_for :product_images, allow_destroy: true
    accepts_attachments_for :product_images, append: true

    # Generate materialized path
    before_validation :set_materialized_path

    validates :name, :price, presence: true

    # Always include translations
    default_scope { includes(:translations) }

    # Globalize translates
    # Virtual attributes need to be defined because of Rails 5.1 Attributes API
    [:name, :description, :seo_title, :seo_description, :materialized_path].each do |attr|
      attribute attr
      translates attr, fallbacks_for_empty_translations: true
    end

    # Active product
    scope :active, -> { where(active: true) }

    # Postgres-specific queries for the jsonb column
    scope :where_any_tags, -> (key, value) do
      value = [value] unless value.kind_of?(Array)
      where("spina_shop_products.properties->'#{key}' ?| array['#{value.join('\',\'')}']")
    end

    scope :where_all_tags, -> (key, value) do
      value = [value] unless value.kind_of?(Array)
      where("spina_shop_products.properties->'#{key}' ?& array['#{value.join('\',\'')}']")
    end

    scope :where_in_range, -> (key, min, max) { where("CAST(coalesce(NULLIF(REPLACE(spina_shop_products.properties->>'#{key}', ',', '.'), ''), '0') AS numeric) BETWEEN ? AND ?", min, max) }

    def price_for_customer(customer)
      price
    end

    def in_stock?
      stock_level > 0
    end

    # All properties are dynamically stored using jsonb
    def properties
      decorate_with_methods(read_attribute(:properties))
    end

    # Get products by filtering their properties
    # Based on querying the jsonb column using Postgres
    def self.filtered(filters)
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
        end
      end

      return products
    end

    def cache_stock_level
      update_columns(
        stock_level: stock_level_adjustments.sum(:adjustment), 
        sales_count: stock_level_adjustments.where('adjustment < ?', 0).sum(:adjustment) * -1,
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
        self.materialized_path = localized_materialized_path
        self.materialized_path += "-#{self.class.where(materialized_path: materialized_path).count}" if self.class.where(materialized_path: materialized_path).where.not(id: id).count > 0
        materialized_path
      end

      def localized_materialized_path
        if I18n.locale == I18n.default_locale
          name.try(:parameterize).prepend('/products/')
        else
          name.try(:parameterize).prepend("/#{I18n.locale}/products/").gsub(/\/\z/, "")
        end
      end

  end
end
