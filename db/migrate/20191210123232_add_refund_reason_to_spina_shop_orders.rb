class AddRefundReasonToSpinaShopOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_orders, :refund_reason, :string
  end
end
