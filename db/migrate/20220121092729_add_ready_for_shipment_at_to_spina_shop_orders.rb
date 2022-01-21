class AddReadyForShipmentAtToSpinaShopOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :spina_shop_orders, :ready_for_shipment_at, :datetime
  end
end
