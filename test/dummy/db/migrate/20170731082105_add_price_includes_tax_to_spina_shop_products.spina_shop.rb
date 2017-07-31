# This migration comes from spina_shop (originally 20170731082027)
class AddPriceIncludesTaxToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :price_includes_tax, :boolean, default: true, null: false
  end
end
