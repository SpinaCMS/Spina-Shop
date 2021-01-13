class AddStatisticsToSpinaShopProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_products, :statistics_reorder_point, :integer, default: 0, null: false
    add_column :spina_shop_products, :statistics_eoq, :integer, default: 0, null: false
    add_column :spina_shop_products, :statistics_safety_stock, :integer, default: 0, null: false
  end
end
