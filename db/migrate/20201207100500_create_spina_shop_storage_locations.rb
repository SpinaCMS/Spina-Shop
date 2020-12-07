class CreateSpinaShopStorageLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_storage_locations do |t|
      t.string :name
      t.boolean :primary
      t.timestamps
    end
    
    add_column :spina_shop_locations, :storage_location_id, :integer
    add_index :spina_shop_locations, :storage_location_id
    add_column :spina_shop_locations, :location_id, :integer
    add_index :spina_shop_locations, :location_id
    
    add_column :spina_shop_locations, :code, :string
  end
end
