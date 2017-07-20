class AddVatIdToSpinaShopCustomers < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_customers, :vat_id, :string
  end
end
