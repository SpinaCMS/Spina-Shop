class CreateSpinaShopOrderPickItems < ActiveRecord::Migration[6.0]
  def change
    create_table :spina_shop_order_pick_items do |t|
      t.integer :order_id, null: false
      t.integer :product_id, null: false
      t.integer :order_item_id, null: false
      t.integer :quantity, default: 0, null: false
      t.timestamps
    end
    
    add_index :spina_shop_order_pick_items, :order_id
    add_index :spina_shop_order_pick_items, :product_id
    add_index :spina_shop_order_pick_items, :order_item_id
  end
end
