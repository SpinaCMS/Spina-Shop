class AddRefundedAtToSpinaShopOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_orders, :refunded_at, :datetime
  end
end
