class AddSupplierIdToSpinaShopProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_products, :supplier_id, :integer, index: true
  end
end
