# This migration comes from spina_shop (originally 20170717125930)
class AddStockEnabledToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :stock_enabled, :boolean, default: false, null: false
  end
end
