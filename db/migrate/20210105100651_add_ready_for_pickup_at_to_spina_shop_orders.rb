class AddReadyForPickupAtToSpinaShopOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_orders, :ready_for_pickup_at, :datetime
  end
end
