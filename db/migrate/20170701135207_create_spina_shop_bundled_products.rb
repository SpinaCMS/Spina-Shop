class CreateSpinaShopBundledProducts < ActiveRecord::Migration[5.1]
  def change
    drop_table "spina_shop_bundled_product_items"
    create_table :spina_shop_bundled_products do |t|
      t.integer "product_id", index: true
      t.integer "product_bundle_id", index: true
      t.integer "quantity", default: 0, null: false
      t.timestamps
    end
  end
end