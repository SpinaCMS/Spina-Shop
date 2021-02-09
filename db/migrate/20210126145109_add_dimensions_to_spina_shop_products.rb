class AddDimensionsToSpinaShopProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_products, :length, :decimal, precision: 8, scale: 1, default: 0, null: false
    add_column :spina_shop_products, :width, :decimal, precision: 8, scale: 1, default: 0, null: false
    add_column :spina_shop_products, :height, :decimal, precision: 8, scale: 1, default: 0, null: false
  end
end
