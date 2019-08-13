class AddPostpayAllowedToSpinaShopCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_customers, :postpay_allowed, :boolean, default: false, null: false
  end
end
