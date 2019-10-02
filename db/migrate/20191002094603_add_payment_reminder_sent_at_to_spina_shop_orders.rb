class AddPaymentReminderSentAtToSpinaShopOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_orders, :payment_reminder_sent_at, :datetime
  end
end
