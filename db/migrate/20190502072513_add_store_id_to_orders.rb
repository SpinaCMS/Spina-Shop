class AddStoreIdToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_orders, :store_id, :integer
    add_index :spina_shop_orders, :store_id

    add_column :spina_shop_customers, :store_id, :integer
    add_index :spina_shop_customers, :store_id

    add_column :spina_shop_customer_groups, :store_id, :integer
    add_index :spina_shop_customer_groups, :store_id
  end
end
