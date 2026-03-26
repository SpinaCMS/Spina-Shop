module Spina::Shop
  module Admin
    module ProductsHelper

      def stores
        @stores ||= Store.order(:name)
      end

      def suppliers
        @suppliers ||= Supplier.order(:name)
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

      # Filter form uses params[:q]; these replace Ransack helpers on the old @q search object.
      def products_index_filters_active?
        products_index_q_params_hash.any? { |_, v| products_index_filter_value_present?(v) }
      end

      def products_index_filters_count
        products_index_q_params_hash.count { |_, v| products_index_filter_value_present?(v) }
      end

      private

      def products_index_q_params_hash
        q = params[:q]
        return {} if q.blank?

        hash = q.respond_to?(:to_unsafe_h) ? q.to_unsafe_h : q.to_h
        hash.symbolize_keys
      end

      def products_index_filter_value_present?(value)
        case value
        when Array then value.any?(&:present?)
        else value.present?
        end
      end

    end
  end
end