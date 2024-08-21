class CreateSpinaShopProductReturnItems < ActiveRecord::Migration[6.1]
  def change
    create_table :spina_shop_product_return_items do |t|
      t.integer :product_return_id, null: false, index: true
      t.integer :quantity, null: false
      t.integer :returned_quantity, null: false, default: 0
      t.integer :product_id, null: false, index: true

      t.timestamps
    end
  end
end
