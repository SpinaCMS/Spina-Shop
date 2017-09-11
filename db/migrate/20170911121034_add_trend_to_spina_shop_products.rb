class AddTrendToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :trend, :decimal, precision: 8, scale: 3, default: "0.0", null: false
  end
end
