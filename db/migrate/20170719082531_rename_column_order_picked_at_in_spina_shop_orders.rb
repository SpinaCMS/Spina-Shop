class RenameColumnOrderPickedAtInSpinaShopOrders < ActiveRecord::Migration[5.1]
  def change
    rename_column :spina_shop_orders, :order_picked_at, :order_prepared_at
  end
end
