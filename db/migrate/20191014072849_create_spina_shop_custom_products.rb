class CreateSpinaShopCustomProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_custom_products do |t|
      t.string :name
      t.decimal :price, precision: 8, scale: 2, default: "0.0", null: false
      t.integer :tax_group_id
      t.integer :sales_category_id
      t.timestamps
    end

    add_index :spina_shop_custom_products, :tax_group_id
    add_index :spina_shop_custom_products, :sales_category_id

    add_foreign_key "spina_shop_custom_products", "spina_shop_tax_groups", column: "tax_group_id"
    add_foreign_key "spina_shop_custom_products", "spina_shop_sales_categories", column: "sales_category_id"
  end
end
