class AddMagicTokensToSpinaShopCustomerAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_customer_accounts, :magic_link_token, :string
    add_column :spina_shop_customer_accounts, :magic_link_sent_at, :datetime
  end
end
