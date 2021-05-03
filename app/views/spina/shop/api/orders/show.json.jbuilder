json.(@order, :id, :billing_name, :received_at, :note, :delivery_name, :delivery_address, :delivery_postal_code, :delivery_city)
json.label [@order.store&.initials, @order.number].compact.join("-")
json.number @order.number

json.store do
  json.initials @order.store&.initials
  json.color @order.store&.color
end

json.delivery_country do
  json.(@order.delivery_country, :name, :code)
end

json.order_items @order.order_items do |order_item|
  json.(order_item, :id, :quantity, :order_id)
  json.name order_item.description
  json.location order_item.orderable.location
  json.ean order_item.orderable.ean
end
