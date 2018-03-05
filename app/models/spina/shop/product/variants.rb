module Spina::Shop
  module Product::Variants
    extend ActiveSupport::Concern

    included do
      belongs_to :parent, class_name: "Product", optional: true
      has_many :children, class_name: "Product", foreign_key: :parent_id, dependent: :nullify

      before_validation(if: :variant?) do
        set_name
        set_parent_product_properties
        set_parent_relations
      end

      before_create :first_variant, if: :variant?
      before_save :set_variant_name
      before_save :set_abstract
      before_save :set_parent, if: :variant?
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
      (parent || self).children.order(:created_at).to_a
    end

    def can_have_variants?
      product_category.variant_properties.any? if product_category.present?
    end

    def variant_override?(attribute)
      variant_overrides.try(:[], attribute.to_s).present?
    end

    private

      def first_variant
        return if parent.has_children?
        new_parent = parent.dup
        new_parent.parent_id = nil
        new_parent.sku = nil
        new_parent.stores = parent.stores
        new_parent.product_collections = parent.product_collections
        new_parent.related_products = parent.related_products
        new_parent.save

        parent.update_columns(parent_id: new_parent.id)
        self[:parent_id] = new_parent.id
      end

      def set_abstract
        self[:abstract] = parent? && has_children?
      end

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

      def set_parent
        self.parent_id = parent.parent_id || parent.id
      end

      def set_parent_product_properties
        attributes = %w(name product_category must_be_of_age_to_buy)
        attributes << :active unless parent.active

        unless variant_override?(:pricing)
          attributes += %w(base_price tax_group_id price_includes_tax price_exceptions)
        end

        unless variant_override?(:sales_category)
          attributes << :sales_category_id
        end

        assign_attributes(attributes.map do |property|
          {property => parent.send(property)}
        end.reduce({}, :merge))
      end

      def set_parent_relations
        self.stores = parent.stores
        self.product_collections = parent.product_collections
        self.related_products = parent.related_products
      end

  end
end