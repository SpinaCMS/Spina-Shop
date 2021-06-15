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
  json.quantity_products order.order_items.products.sum(:quantity) + order.order_items.product_bundles.joins("INNER JOIN spina_shop_product_bundles ON spina_shop_product_bundles.id = spina_shop_order_items.orderable_id INNER JOIN spina_shop_bundled_products ON spina_shop_bundled_products.product_bundle_id = spina_shop_product_bundles.id").sum("spina_shop_bundled_products.quantity * spina_shop_order_items.quantity")
  json.quantity_product_bundles order.order_items.product_bundles.sum(:quantity)
  json.current_state I18n.t("orders.states.#{order.current_state}")
end