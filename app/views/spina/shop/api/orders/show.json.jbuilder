json.(@order, :id, :billing_name, :received_at, :note, :delivery_name, :delivery_address, :delivery_postal_code, :delivery_city)
json.label [@order.store&.initials, @order.number].compact.join("-")
json.number @order.number
json.delivery_option @order.delivery_option&.name

json.store do
  json.initials @order.store&.initials
  json.color @order.store&.color
end

json.delivery_country do
  json.(@order.delivery_country, :name, :code)
end

json.order_items @order.order_pick_list.items do |product|
  json.(product, :id, :quantity, :order_id, :location, :ean, :location, :name)
end
