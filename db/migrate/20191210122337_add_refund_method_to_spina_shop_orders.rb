class AddRefundMethodToSpinaShopOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_orders, :refund_method, :string
  end
end
