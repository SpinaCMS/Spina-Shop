module Spina::Shop
  module Admin
    module ProductsHelper

      def product_image_tag(product_image, variant: {})
        image_tag main_app.url_for(product_image.file.variant(variant))
      rescue 
        ""
      end

      def stores
        @stores ||= Store.order(:name)
      end

      def product_collections
        @product_collections ||= ProductCollection.all
      end

      def customer_groups_for_select
        @customer_groups ||= CustomerGroup.where(parent_id: nil).order(:name).map do |group|
          [[group.name, group.id]] + group.children.order(:name).map do |child_group|
            ["– #{child_group.name}", child_group.id]
          end
        end.flatten(1)
      end

      def stores_for_select
        Spina::Shop::Store.all.map{|g|[g.name, g.id]}
      end

      def grouped_options_for_pricing_select
        stores = stores_for_select.map{|store| [store.first, "store[#{store.last}]"]}
        customer_groups = customer_groups_for_select.map{|group| [group.first, "customer_group[#{group.last}]"]}

        [[Spina::Shop::Store.model_name.human(count: 2), stores], 
        [Spina::Shop::CustomerGroup.model_name.human(count: 2), customer_groups]]
      end

    end
  end
end