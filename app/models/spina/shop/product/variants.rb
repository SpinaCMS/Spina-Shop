module Spina::Shop
  module Product::Variants
    extend ActiveSupport::Concern

    included do
      belongs_to :parent, class_name: "Product", optional: true, counter_cache: :children_count
      has_many :children, class_name: "Product", foreign_key: :parent_id

      before_validation(if: :variant?) do
        set_name
        set_parent_product_properties
        set_parent_relations
      end

      # When you create your first variant, make sure to create a new parent
      # This way it won't interfere with existing orders
      before_create :create_first_variant, if: :variant?

      before_save :set_variant_name
      before_save :set_parent, if: :variant?
      after_save { children.each(&:save) }

      scope :variants, -> { where.not(parent_id: nil) }
      scope :roots, -> { where(parent_id: nil) }

      # Only products with no children are purchasable
      scope :purchasable, -> { where(children_count: 0) }

      translates :variant_name, fallbacks: true
    end

    # Root product
    def root
      parent || self
    end

    def full_name
      [name, variant_name].compact.join(' / ')
    end

    def purchasable?
      children_count.zero?
    end

    def not_purchasable?
      !purchasable?
    end

    def variant?
      parent_id.present?
    end

    def parent?
      !variant?
    end

    def has_children?
      children_count > 0
    end

    def has_variants?
      variant? || has_children?
    end

    def variants
      root.children.order(:created_at).to_a
    end

    def can_have_variants?
      product_category.variant_properties.any? if product_category.present?
    end

    def variant_override?(attribute)
      variant_overrides.try(:[], attribute.to_s).present?
    end

    private

      def create_first_variant
        return if parent.has_children?
        new_parent = parent.dup
        new_parent.parent_id = nil
        new_parent.sku = nil
        new_parent.stock_enabled = false
        new_parent.location = ""
        new_parent.stores = parent.stores
        new_parent.product_collections = parent.product_collections
        new_parent.related_products = parent.related_products
        new_parent.save

        new_parent.children << parent
        self[:parent_id] = new_parent.id
      end

      def set_variant_name
        self.variant_name = nil
        return if properties.blank?
        self.variant_name = product_category.variant_properties.map do |property|
          properties.send(property.name).try(:label)
        end.try(:join, ' - ').gsub(/\s-\s\z/, "")
      end

      def set_parent
        self.parent_id = parent.parent_id || parent.id
      end

      def set_parent_product_properties
        assign_attributes(parent_attributes.map do |property|
          {property => parent.send(property)}
        end.reduce({}, :merge))
      end

      def parent_attributes
        attributes = %w(name product_category must_be_of_age_to_buy)
        attributes << :active unless parent.active
        attributes << :sales_category_id unless variant_override?(:sales_category)
        attributes += pricing_attributes unless variant_override?(:pricing)
        attributes
      end

      def pricing_attributes
        %w(base_price tax_group_id price_includes_tax price_exceptions)
      end

      def set_parent_relations
        self.stores = parent.stores unless variant_override?(:stores)
      end

  end
end