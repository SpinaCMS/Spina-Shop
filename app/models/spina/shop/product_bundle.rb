module Spina::Shop
  class ProductBundle < ApplicationRecord
    # Stores the old path when generating a new materialized_path
    attr_accessor :old_path

    belongs_to :tax_group
    belongs_to :sales_category

    has_many :product_images, dependent: :destroy
    
    has_many :bundled_products, dependent: :destroy
    has_many :products, through: :bundled_products

    has_many :in_stock_reminders, as: :orderable, dependent: :destroy

    has_many :order_items, as: :orderable, dependent: :restrict_with_exception

    accepts_nested_attributes_for :bundled_products, :product_images, allow_destroy: true

    # Generate materialized path
    before_validation :set_materialized_path

    # Create a 301 redirect if materialized_path changed
    after_save :rewrite_rule

    validates :name, :price, presence: true

    # Active product bundles
    scope :active, -> { where(active: true, archived: false) }

    # Mobility translates
    translates :name, :description, :materialized_path
    translates :seo_title, default: -> { name }
    translates :seo_description, default: -> { description }

    def to_s
      name
    end

    def full_name
      name
    end

    # Calculate the price based on this order
    def price_for_order(order)
      price
    end

    def short_description
      description
    end

    def stock_level
      bundled_products.joins(:product).pluck("MIN(stock_level / quantity)")[0].to_i
    end

    def in_stock?
      stock_level > 0
    end

    def weight
      bundled_products.inject(BigDecimal(0)){|t, i| t + (i.product.weight || BigDecimal.new(0)) * i.quantity}
    end

    def cost_price
      bundled_products.inject(BigDecimal(0)){|t, i| t + (i.product.cost_price || BigDecimal.new(0)) * i.quantity}
    end

    def total_of_individual_products
      bundled_products.inject(BigDecimal(0)){|t, i| t + (i.product.price || BigDecimal.new(0)) * i.quantity}
    end

    private

      def rewrite_rule
        Spina::RewriteRule.where(old_path: old_path).first_or_create.update_attributes(new_path: materialized_path) if old_path != materialized_path
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
          name.try(:parameterize).prepend('/product_bundles/')
        else
          name.try(:parameterize).prepend("/#{I18n.locale}/product_bundles/").gsub(/\/\z/, "")
        end
      end
  end
end