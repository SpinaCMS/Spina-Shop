json.array! @orders do |order|
  json.id order.id
  json.number order.number
  json.received_at order.received_at
  json.store do
    json.initials order.store&.initials
    json.color order.store&.color
  end
  json.delivery_option order.delivery_option&.name
  json.quantity_sum order.order_items.sum(:quantity)
  json.current_state I18n.t("orders.states.#{order.current_state}")
end