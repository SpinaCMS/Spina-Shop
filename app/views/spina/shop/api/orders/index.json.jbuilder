json.array! @orders do |order|
  json.id order.id
  json.label [order.store&.initials, order.number].compact.join("-")
  json.delivery_option order.delivery_option&.name
  json.quantity_sum order.order_items.sum(:quantity)
  json.current_state I18n.t("orders.states.#{order.current_state}")
  json.note
end