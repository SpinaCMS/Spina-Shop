module Spina::Shop
  module Product::Variants
    extend ActiveSupport::Concern

    included do
      belongs_to :parent, class_name: "Product", optional: true
      has_many :children, class_name: "Product", foreign_key: :parent_id, dependent: :nullify

      before_validation(if: :variant?) do
        set_name
        set_variant_name
        set_parent_product_properties
        set_parent_relations
      end

      after_save :save_children, if: :has_children?

      translates :variant_name, default: -> { "–" }
    end

    def full_name
      [name, variant_name].compact.join(' / ')
    end

    def variant?
      parent_id.present?
    end

    def parent?
      !variant?
    end

    def has_children?
      children.any?
    end

    def childless?
      !has_children?
    end

    def has_variants?
      variant? || has_children?
    end

    def variants
      (parent || self).children.to_a
    end

    def can_have_variants?
      product_category.variant_properties.any? if product_category.present?
    end

    private

      def set_variant_name
        self.variant_name = nil
        return if properties.blank?
        self.variant_name = product_category.variant_properties.map do |property|
          properties.send(property.name).try(:label)
        end.try(:join, ' - ')
      end

      def save_children
        children.each(&:save)
      end

      def set_parent_product_properties
        assign_attributes(
          name: parent.name, 
          product_category: parent.product_category,
          must_be_of_age_to_buy: parent.must_be_of_age_to_buy
        )
      end

      def set_parent_relations
        self.stores = parent.stores
        self.product_collections = parent.product_collections
        self.related_products = parent.related_products
      end

  end
end