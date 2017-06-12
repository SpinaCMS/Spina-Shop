class AddZoneIdToSpinaShopOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :spina_shop_orders, :zone_id, :integer, index: true
  end
end
