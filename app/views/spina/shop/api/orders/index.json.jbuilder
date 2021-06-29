json.array! @orders do |order|
  json.id order.id
  json.billing_name order.billing_name
  json.delivery_name order.delivery_name
  json.delivery_first_name order.delivery_first_name
  json.delivery_last_name order.delivery_last_name
  json.delivery_full_name order.delivery_full_name
  json.number order.number
  json.received_at order.received_at
  json.store do
    json.initials order.store&.initials
    json.color order.store&.color
  end
  json.delivery_option order.delivery_option&.name
  json.quantity_products order.total_product_items
  json.quantity_product_bundles order.order_items.product_bundles.sum(:quantity)
  json.current_state I18n.t("orders.states.#{order.current_state}")
end