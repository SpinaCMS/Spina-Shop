class AddAverageStockOrderCostToSpinaShopSuppliers < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_suppliers, :average_stock_order_cost, :decimal, precision: 8, scale: 2
  end
end
