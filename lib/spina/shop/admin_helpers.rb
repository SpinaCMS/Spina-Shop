module Spina
  module Shop
    module AdminHelpers

      def link_to_add_product_item_fields(f, association, &block)
        new_object = f.object.send(association).klass.new
        id = new_object.object_id
        fields = f.fields_for(association, new_object, child_index: id) do |builder|
          build_structure_parts(f.object.page_part.name, new_object) if structure_item?(new_object)
          render("bundled_product_items_fields", f: builder)
        end
        link_to '#', class: "add_product_item_fields button button-link button-block", data: {id: id, fields: fields.gsub("\n", "")} do
          block.yield
        end
      end

      def link_to_add_property_option_fields(f, association, &block)
        new_object = f.object.send(association).klass.new
        id = new_object.object_id
        fields = f.fields_for(association, new_object, child_index: id) do |builder|
          build_structure_parts(f.object.page_part.name, new_object) if structure_item?(new_object)
          render partial: "spina/shop/admin/settings/product_category_properties/property_options_fields", locals: {f: builder}
        end
        link_to '#', class: "add_property_option_fields button button-link button-block", data: {id: id, fields: fields.gsub("\n", "")} do
          block.yield
        end
      end

    end
  end
end