class AddStoreIdToSpinaShopCustomerAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_customer_accounts, :store_id, :integer
    add_index :spina_shop_customer_accounts, :store_id
    remove_index :spina_shop_customer_accounts, name: :idx_shop_customer_accounts_on_email
    add_index :spina_shop_customer_accounts, [:email, :store_id], unique: true
  end
end
