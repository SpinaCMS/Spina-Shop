class AddStockLevelToSpinaShopProductLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :spina_shop_product_locations, :stock_level, :integer, default: 0, null: false
  end
end
