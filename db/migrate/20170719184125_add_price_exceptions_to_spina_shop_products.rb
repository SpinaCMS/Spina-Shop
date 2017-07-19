class AddPriceExceptionsToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :price_exceptions, :jsonb, null: false, default: "{}"
  end
end
