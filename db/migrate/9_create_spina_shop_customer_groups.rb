class CreateSpinaShopCustomerGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :spina_shop_customer_groups do |t|
      t.string :name
      t.timestamps
    end

    add_column :spina_shop_customers, :customer_group_id, :integer
    add_index :spina_shop_customers, :customer_group_id
  end
end
