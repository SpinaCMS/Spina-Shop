json.(@order, :id, :number, :billing_name, :received_at, :note, :delivery_name, :delivery_first_name, :delivery_last_name, :delivery_full_name, :delivery_address, :delivery_postal_code, :delivery_city, :allowed_transitions)
json.label [@order.store&.initials, @order.number].compact.join("-")
json.delivery_option @order.delivery_option&.name
json.delivery_option_label I18n.t("delivery_options.#{@order.delivery_option&.name}.name")
json.current_state I18n.t("spina.shop.orders.states.#{@order.current_state}")

json.store do
  json.initials @order.store&.initials
  json.color @order.store&.color
end

json.delivery_country do
  json.(@order.delivery_country, :name, :code)
end

json.order_pick_list @order.order_pick_list.items do |product|
  json.(product, :id, :quantity, :order_id, :order_item_id, :ean, :location, :stock_level, :name, :locations)
end

json.order_items @order.order_items do |order_item|
  json.(order_item, :id, :quantity, :description)
  if order_item.is_product_bundle?
    json.bundled_products order_item.orderable.bundled_products do |bundled_product|
      json.quantity bundled_product.quantity
      json.name bundled_product.product.name
    end
  end
end
