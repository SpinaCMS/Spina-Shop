class CreateSpinaShopAvailableProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :spina_shop_available_products do |t|
      t.integer :product_id
      t.integer :store_id

      t.timestamps
    end

    add_index :spina_shop_available_products, :product_id
    add_index :spina_shop_available_products, :store_id
  end
end
