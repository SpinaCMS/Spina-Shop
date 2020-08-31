class CreateSpinaShopLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_locations do |t|
      t.string :name
      t.boolean :primary, default: false, null: false

      t.timestamps
    end
  end
end
