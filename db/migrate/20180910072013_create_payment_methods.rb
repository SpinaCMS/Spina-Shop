class CreatePaymentMethods < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_payment_methods do |t|
      t.string :name
      t.decimal :price, precision: 8, scale: 2, default: "0.0", null: false
      t.integer :tax_group_id
      t.integer :sales_category_id
      t.boolean :price_includes_tax, default: true, null: false
      t.integer :position
      t.timestamps
    end

    add_index :spina_shop_payment_methods, :tax_group_id
    add_index :spina_shop_payment_methods, :sales_category_id

    add_column :spina_shop_orders, :payment_method_id, :integer
    add_index :spina_shop_orders, :payment_method_id
  end
end
