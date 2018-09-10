class AddPaymentMethodCacheColumnsToSpinaShopOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_orders, :payment_method_price, :decimal, precision: 8, scale: 2
    add_column :spina_shop_orders, :payment_method_tax_rate, :decimal, precision: 8, scale: 2
    add_column :spina_shop_orders, :payment_method_metadata, :jsonb, default: "{}", null: false
  end
end
