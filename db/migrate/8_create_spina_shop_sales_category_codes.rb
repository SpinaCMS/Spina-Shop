class CreateSpinaShopSalesCategoryCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :spina_shop_sales_category_codes do |t|
      t.string :code
      t.string :sales_categorizable_type
      t.integer :sales_categorizable_id
      t.integer :sales_category_id
      t.timestamps
    end
    add_index :spina_shop_sales_category_codes, :sales_categorizable_id
    add_index :spina_shop_sales_category_codes, :sales_category_id
  end
end
