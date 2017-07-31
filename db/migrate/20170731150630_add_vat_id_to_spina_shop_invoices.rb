class AddVatIdToSpinaShopInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_invoices, :vat_id, :string
  end
end
