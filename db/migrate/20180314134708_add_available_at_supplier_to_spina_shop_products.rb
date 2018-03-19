class AddAvailableAtSupplierToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :available_at_supplier, :boolean, default: true, null: false
    add_column :spina_shop_products, :waiting_for_stock, :boolean, default: false, null: false
  end
end
