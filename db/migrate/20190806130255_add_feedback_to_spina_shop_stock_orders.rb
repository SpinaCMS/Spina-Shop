class AddFeedbackToSpinaShopStockOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_stock_orders, :feedback, :text
  end
end
