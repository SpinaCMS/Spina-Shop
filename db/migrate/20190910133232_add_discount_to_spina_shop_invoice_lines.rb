class AddDiscountToSpinaShopInvoiceLines < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_invoice_lines, :discount, :decimal, precision: 8, scale: 2, default: "0.0", null: false
  end
end
