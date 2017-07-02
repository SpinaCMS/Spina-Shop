# This migration comes from spina_shop (originally 7)
class CreateSpinaShopProductCollections < ActiveRecord::Migration[5.1]
  def change
    create_table :spina_shop_collectables do |t|
      t.integer :product_id
      t.integer :product_collection_id
      t.timestamps
    end
    add_index :spina_shop_collectables, :product_id
    add_index :spina_shop_collectables, :product_collection_id

    create_table :spina_shop_product_collections do |t|
      t.string :name
      t.timestamps
    end
  end
end
