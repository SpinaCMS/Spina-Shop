class CreateSpinaShopProductsSuppliers < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_products_suppliers do |t|
      t.integer :product_id
      t.integer :supplier_id
    end
    add_index :spina_shop_products_suppliers, :product_id
    add_index :spina_shop_products_suppliers, :supplier_id
  end
end
