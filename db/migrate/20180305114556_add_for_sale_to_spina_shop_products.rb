class AddForSaleToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :sellable, :boolean, default: true, null: false
  end
end
