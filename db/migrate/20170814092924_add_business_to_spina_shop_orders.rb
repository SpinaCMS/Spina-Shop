class AddBusinessToSpinaShopOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_orders, :business, :boolean, default: false, null: false
    add_column :spina_shop_invoices, :vat_reverse_charge, :boolean, default: false, null: false
  end
end
