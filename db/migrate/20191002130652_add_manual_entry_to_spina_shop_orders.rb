class AddManualEntryToSpinaShopOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_orders, :manual_entry, :boolean, default: false, null: false
  end
end
