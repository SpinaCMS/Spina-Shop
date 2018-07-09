class AddAutoToSpinaShopDiscounts < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_discounts, :auto, :boolean, default: false, null: false
  end
end
