json.id @order.id
json.order_items @order.order_items do |order_item|
  json.id order_item.id
  json.name order_item.description
  json.quantity order_item.quantity
  json.location order_item.orderable.location
  json.ean order_item.orderable.ean
  json.order_id order_item.order_id
end