class AddPaidToSpinaShopInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_invoices, :paid, :boolean, default: true, null: false
  end
end
