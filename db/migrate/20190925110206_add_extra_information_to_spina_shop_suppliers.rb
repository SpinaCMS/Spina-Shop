class AddExtraInformationToSpinaShopSuppliers < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_suppliers, :contact_name, :string
    add_column :spina_shop_suppliers, :email, :citext
    add_column :spina_shop_suppliers, :phone, :string
    add_column :spina_shop_suppliers, :note, :text

    add_column :spina_shop_stock_orders, :reference, :string
  end
end
