module Spina
  class Product < ApplicationRecord
    belongs_to :product_category

    has_many :product_items, dependent: :restrict_with_exception # Don't destroy product if it has items

    has_many :product_images, dependent: :destroy
    has_many :product_reviews, dependent: :destroy

    # Related products
    has_many :product_relations, dependent: :destroy
    has_many :related_products, through: :product_relations

    accepts_nested_attributes_for :product_items, :product_images, allow_destroy: true
    accepts_attachments_for :product_images, append: true

    validates :name, presence: true

    translates :name, :description, :seo_title, :seo_description, :materialized_path, fallbacks_for_empty_translations: true

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

    def average_review_score
      product_reviews.average(:average_score).try(:round, 1)
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
          products = products.where_in_range(filter[:property], filter[:value]["min"].to_d.presence || 0, filter[:value]["max"].to_d.presence || 0)
        when "decimal"
          if filter[:property] == 'volume'
            products = products.items_where_in_range(filter[:property], filter[:value]["min"].to_d.presence || 0, filter[:value]["max"].to_d.presence || 0)
          else
            products = products.where_in_range(filter[:property], filter[:value]["min"].to_d.presence || 0, filter[:value]["max"].to_d.presence || 0)
          end
        when "number"
          products = products.where_in_range(filter[:property], filter[:value]["min"].to_d.presence || 0, filter[:value]["max"].to_d.presence || 0)
        end
      end

      return products
    end
  end
end
