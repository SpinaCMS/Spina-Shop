class AddSupplierPackingUnitToSpinaShopProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_products, :supplier_packing_unit, :integer, null: false, default: 1
  end
end
