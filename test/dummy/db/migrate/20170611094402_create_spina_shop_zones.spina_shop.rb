# This migration comes from spina_shop (originally 3)
class CreateSpinaShopZones < ActiveRecord::Migration[5.0]
  def change
    create_table :spina_shop_zones do |t|
      t.string :name, null: false
      t.string :zone_type, null: false
      t.integer :parent_id
      t.timestamps
    end
  end
end
