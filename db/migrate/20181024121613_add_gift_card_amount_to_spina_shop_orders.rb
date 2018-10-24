class AddGiftCardAmountToSpinaShopOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_orders, :gift_card_amount, :decimal, precision: 8, scale: 2
  end
end
