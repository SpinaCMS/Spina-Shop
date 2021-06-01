json.array! @orders do |order|
  json.id order.id
  json.billing_name order.billing_name
  json.number order.number
  json.received_at order.received_at
  json.store do
    json.initials order.store&.initials
    json.color order.store&.color
  end
  json.delivery_option order.delivery_option&.name
  json.quantity_products order.order_items.products.sum(:quantity)
  json.quantity_product_bundles order.order_items.product_bundles.sum(:quantity)
  json.current_state I18n.t("orders.states.#{order.current_state}")
end