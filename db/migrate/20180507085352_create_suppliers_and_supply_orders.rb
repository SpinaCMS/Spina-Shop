class CreateSuppliersAndSupplyOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_suppliers do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :spina_shop_supply_orders do |t|
      t.integer :supplier_id, index: true
      t.datetime :closed_at
      t.text :note
      t.string :delivery_tracking_url
      t.date :expected_delivery
      t.datetime :received_at
      t.datetime :ordered_at
      t.timestamps
    end

    create_table :spina_shop_ordered_supply do |t|
      t.integer :supply_order_id, index: true
      t.integer :product_id, index: true
      t.integer :quantity, null: false
      t.integer :received, null: false, default: 0
    end
  end
end
