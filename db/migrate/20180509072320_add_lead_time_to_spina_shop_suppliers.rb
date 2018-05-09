class AddLeadTimeToSpinaShopSuppliers < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_suppliers, :lead_time, :integer, default: 0, null: false
  end
end
