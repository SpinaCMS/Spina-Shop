class AddParentIdToSpinaShopCustomerGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_customer_groups, :parent_id, :integer
    add_index :spina_shop_customer_groups, :parent_id
  end
end
