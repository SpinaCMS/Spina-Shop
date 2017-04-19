module Spina
  class Product < ApplicationRecord
    belongs_to :product_category

    has_many :product_items, inverse_of: :product, dependent: :destroy

    has_many :product_images, dependent: :destroy

    # Reviews
    has_many :product_reviews, dependent: :destroy

    # Related products
    has_many :product_relations, dependent: :destroy
    has_many :related_products, through: :product_relations

    # Favorites
    has_many :favorites, dependent: :destroy

    # Cache averages for quick ordering
    before_save :cache_averages

    before_validation :set_materialized_path

    accepts_nested_attributes_for :product_items, :product_images, allow_destroy: true
    accepts_attachments_for :product_images, append: true

    validates :name, presence: true

    translates :name, :description, :seo_title, :seo_description, :materialized_path, fallbacks_for_empty_translations: true

    # Active product
    scope :active, -> { where(active: true) }

    scope :where_any_tags, -> (key, value) do
      value = [value] unless value.kind_of?(Array)
      where("spina_products.properties->'#{key}' ?| array['#{value.join('\',\'')}']")
    end

    scope :where_all_tags, -> (key, value) do
      value = [value] unless value.kind_of?(Array)
      where("spina_products.properties->'#{key}' ?& array['#{value.join('\',\'')}']")
    end

    scope :where_in_range, -> (key, min, max) { where("CAST(coalesce(NULLIF(spina_products.properties->>'#{key}', ''), '0') AS numeric) BETWEEN ? AND ?", min, max) }

    scope :items_where_in_range, -> (key, min, max) { joins(:product_items).where("CAST(coalesce(NULLIF(spina_product_items.properties->>'#{key}', ''), '0') AS numeric) BETWEEN ? AND ?", min, max) }

    def to_s
      name
    end

    def to_param
      materialized_path
    end

    def default_product_item
      product_items.active.first
    end

    # Products filtered by filters
    def self.filtered(filters)
      products = all

      filters ||= []
      filters.each do |filter|
        case filter[:field_type]
        when "select"
          products = products.where_any_tags(filter[:property], filter[:value])
        when "percentage"
          if filter[:value]["min"].present? && filter[:value]["max"].present?
            products = products.where_in_range(filter[:property], filter[:value]["min"].presence.try(:to_d) || 0, filter[:value]["max"].presence.try(:to_d) || 0)
          end
        when "decimal"
          if filter[:value]["min"].present? && filter[:value]["max"].present?
            products = products.where_in_range(filter[:property], filter[:value]["min"].presence.try(:to_d) || 0, filter[:value]["max"].presence.try(:to_d) || 0)
          end
        when "number"
          if filter[:value]["min"].present? && filter[:value]["max"].present?
            products = products.where_in_range(filter[:property], filter[:value]["min"].presence.try(:to_d) || 0, filter[:value]["max"].presence.try(:to_d) || 0)
          end
        end
      end

      return products
    end

    private

      def set_materialized_path
        self.materialized_path = name.try(:parameterize)
        self.materialized_path += "-#{self.class.where(materialized_path: materialized_path).count}" if self.class.where(materialized_path: materialized_path).where.not(id: id).count > 0
        materialized_path
      end

      def cache_averages
        write_attribute :average_review_score, product_reviews.average(:score).try(:round, 1)
        write_attribute :sales_count, product_items.joins(:stock_level_adjustments).where('adjustment < ?', 0).sum(:adjustment) * -1
        write_attribute :lowest_price, product_items.minimum(:price)
        write_attribute :active, product_items.any?(&:active)
      end
  end
end
