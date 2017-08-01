class AddPriceIncludesTaxToSpinaShopDeliveryOptions < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_delivery_options, :price_includes_tax, :boolean, default: true, null: false
  end
end
