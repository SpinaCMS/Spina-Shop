json.(@order, :id, :billing_name, :received_at, :note)
json.label [@order.store&.initials, @order.number].compact.join("-")

json.order_items @order.order_items do |order_item|
  json.(order_item, :id, :quantity, :order_id)
  json.name order_item.description
  json.location order_item.orderable.location
  json.ean order_item.orderable.ean
end
