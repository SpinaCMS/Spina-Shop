class AddOriginalPriceToSpinaShopProductBundles < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_product_bundles, :original_price, :decimal, precision: 8, scale: 2
  end
end
