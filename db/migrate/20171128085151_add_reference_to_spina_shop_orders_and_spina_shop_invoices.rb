class AddReferenceToSpinaShopOrdersAndSpinaShopInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_orders, :reference, :string
    add_column :spina_shop_invoices, :reference, :string
  end
end
