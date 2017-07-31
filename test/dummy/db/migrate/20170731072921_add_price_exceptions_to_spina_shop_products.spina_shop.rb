# This migration comes from spina_shop (originally 20170719184125)
class AddPriceExceptionsToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :price_exceptions, :jsonb, null: false, default: "{}"
  end
end
