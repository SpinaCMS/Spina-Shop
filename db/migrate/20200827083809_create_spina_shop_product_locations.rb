class CreateSpinaShopProductLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_product_locations do |t|
      t.integer :product_id
      t.integer :location_id
      t.string :location_code
      t.timestamps
    end

    add_index :spina_shop_product_locations, :product_id
    add_index :spina_shop_product_locations, :location_id
  end
end
