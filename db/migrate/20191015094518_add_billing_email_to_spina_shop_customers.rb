class AddBillingEmailToSpinaShopCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_customers, :billing_email, :citext
  end
end
