class CreateSpinaShopLocationCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_location_codes do |t|
      t.string :code, null: false
      t.integer :location_id

      t.timestamps
    end
    
    add_index :spina_shop_location_codes, :location_id
    add_column :spina_shop_product_locations, :location_code_id, :integer
    add_index :spina_shop_product_locations, :location_code_id
  end
end
