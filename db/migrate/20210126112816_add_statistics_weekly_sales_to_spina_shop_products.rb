class AddStatisticsWeeklySalesToSpinaShopProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_products, :statistics_weekly_sales, :integer, default: 0, null: false
  end
end
