module Spina::Shop
  class Product < ApplicationRecord
    belongs_to :product_category, optional: true

    has_many :product_items, inverse_of: :product, dependent: :destroy
    has_many :product_images, dependent: :destroy
    has_many :product_reviews, dependent: :destroy
    has_many :product_relations, dependent: :destroy
    has_many :related_products, through: :product_relations
    has_many :favorites, dependent: :destroy

    accepts_nested_attributes_for :product_items, :product_images, allow_destroy: true
    accepts_attachments_for :product_images, append: true

    # Cache averages for quick ordering
    before_save :cache_averages
    before_validation :set_materialized_path

    validates :name, presence: true

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

    scope :items_where_in_range, -> (key, min, max) { joins(:product_items).where("CAST(coalesce(NULLIF(REPLACE(spina_shop_product_items.properties->>'#{key}', ',', '.'), ''), '0') AS numeric) BETWEEN ? AND ?", min, max) }

    def to_param
      materialized_path
    end

    # First active ProductItem is the default item. TODO: sorting.
    def default_product_item
      product_items.active.first
    end

    # A product is only active if any of it's ProductItems are active
    # Cached in the active column for faster querying in the cache_averages method
    def active?
      product_items.active.any?
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

    private

      # Get all values for properties defined on the ProductCategory.
      # Defines singleton methods on the properties attribute for this product.
      def decorate_with_methods(jsonb)
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
        self.materialized_path = name.try(:parameterize)
        self.materialized_path += "-#{self.class.where(materialized_path: materialized_path).count}" if self.class.where(materialized_path: materialized_path).where.not(id: id).count > 0
        materialized_path
      end

      # After saving this product always make sure to update some cached values
      # Useful for frontend and fast queries
      def cache_averages
        write_attribute :average_review_score, product_reviews.average(:score).try(:round, 1)
        write_attribute :sales_count, product_items.joins(:stock_level_adjustments).where('adjustment < ?', 0).sum(:adjustment) * -1
        write_attribute :lowest_price, product_items.minimum(:price)
        write_attribute :active, product_items.any?(&:active)
      end
  end
end
