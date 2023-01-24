module Spina
  module Shop
    module AdminHelpers

      def link_to_add_volume_discount(f, &block)
        new_object = OpenStruct.new({"discount" => "", "quantity" => ""})
        id = new_object.object_id
        fields = render(partial: 'volume_discount_fields', locals: {f: f, volume_discount: new_object})
        link_to '#', class: "add_volume_discount button button-block button-hollow", style: "margin-right: 0; margin-top: 4px", data: {id: id, fields: fields.gsub("\n", "")} do
          block.yield
        end
      end
      
      def link_to_add_price_exception(f, scope, &block)
        new_object = OpenStruct.new({price: "", "#{scope}_id".to_sym => ""})
        id = new_object.object_id
        fields = render(partial: 'price_exception_fields', locals: {f: f, scope: scope, price_exception: new_object})
        link_to '#', class: "add_price_exception", data: {id: id, fields: fields.gsub("\n", "")} do
          block.yield
        end
      end

      def link_to_add_address(f, association, &block)
        new_object = f.object.send(association).klass.new
        id = new_object.object_id
        fields = f.fields_for(association, new_object, child_index: id) do |builder|
          render("address_fields", f: builder)
        end
        link_to '#', class: "add_address_fields button button-link", data: {id: id, fields: fields.gsub("\n", "")} do
          block.yield
        end
      end

      def link_to_add_product_fields(f, association, &block)
        new_object = f.object.send(association).klass.new
        id = new_object.object_id
        fields = f.fields_for(association, new_object, child_index: id) do |builder|
          render("bundled_products_fields", f: builder)
        end
        link_to '#', class: "add_product_fields button button-link button-block", data: {id: id, fields: fields.gsub("\n", "")} do
          block.yield
        end
      end

      def link_to_add_property_option_fields(f, association, &block)
        new_object = f.object.send(association).klass.new
        id = new_object.object_id
        fields = f.fields_for(association, new_object, child_index: id) do |builder|
          render partial: "spina/shop/admin/settings/property_options/fields", locals: {f: builder}
        end
        link_to '#', class: "add_property_option_fields button button-link button-block", data: {id: id, fields: fields.gsub("\n", "")} do
          block.yield
        end
      end

    end
  end
end