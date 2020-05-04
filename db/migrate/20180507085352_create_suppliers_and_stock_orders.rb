class CreateSuppliersAndStockOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_suppliers do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :spina_shop_stock_orders do |t|
      t.integer :supplier_id, index: true
      t.datetime :closed_at
      t.text :note
      t.string :delivery_tracking_url
      t.date :expected_delivery
      t.datetime :ordered_at
      t.timestamps
    end

    create_table :spina_shop_ordered_stock do |t|
      t.integer :stock_order_id, index: true
      t.integer :product_id, index: true
      t.integer :quantity, null: false
      t.integer :received, null: false, default: 0
    end
  end
end
