class AddDeliveryDetailsToSpinaShopOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_orders, :delivery_first_name, :string
    add_column :spina_shop_orders, :delivery_last_name, :string
    add_column :spina_shop_orders, :delivery_company, :string
  end
end
