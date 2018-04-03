module Spina::Shop
  module Admin
    module ProductsHelper

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

    end
  end
end