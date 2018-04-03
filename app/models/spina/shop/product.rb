module Spina::Shop
  class Product < ApplicationRecord
    include Variants, Pricing

    # Stores the old path when generating a new materialized_path
    attr_accessor :old_path, :initial_stock_level, :files

    belongs_to :tax_group
    belongs_to :sales_category
    belongs_to :product_category, optional: true

    has_many :product_images, dependent: :destroy
    has_many :product_reviews, dependent: :destroy
    has_many :product_relations, dependent: :destroy
    has_many :related_products, through: :product_relations
    has_many :favorites, dependent: :destroy
    has_many :collectables
    has_many :product_collections, through: :collectables, dependent: :destroy
    has_many :available_products
    has_many :stores, through: :available_products, dependent: :destroy

    has_many :order_items, as: :orderable, dependent: :restrict_with_exception
    has_many :stock_level_adjustments, dependent: :destroy
    has_many :in_stock_reminders, as: :orderable, dependent: :destroy

    has_many :bundled_products, dependent: :restrict_with_exception

    accepts_nested_attributes_for :product_images, allow_destroy: true
    accepts_attachments_for :product_images, append: true

    # Generate materialized path
    before_validation :set_materialized_path

    # Create a 301 redirect if materialized_path changed
    after_save :rewrite_rule

    after_create :create_initial_stock_level_adjustment, if: :stock_enabled?

    validates :name, :base_price, presence: true
    validates :sku, uniqueness: true, allow_blank: true

    # Mobility translates
    translates :name, :description, :materialized_path
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

      return hide_variants ? all.where(parent_id: nil, id: products.select("CASE WHEN parent_id IS NULL THEN id ELSE parent_id END")) : products
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

      def rewrite_rule
        Spina::RewriteRule.where(old_path: old_path).first_or_create.update_attributes(new_path: materialized_path) if old_path != materialized_path
      end

      def create_initial_stock_level_adjustment
        ChangeStockLevel.new(self, adjustment: initial_stock_level).save
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
        if Spina.config.locale_paths.present?
          full_name.try(:parameterize).prepend("#{Spina.config.locale_paths[I18n.locale.to_sym]}/products/").gsub(/\/\z/, "")
        else
          if I18n.locale == I18n.default_locale
            full_name.try(:parameterize).prepend('/products/')
          else
            full_name.try(:parameterize).prepend("/#{I18n.locale}/products/").gsub(/\/\z/, "")
          end
        end
      end

  end
end
