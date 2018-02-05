class AddActiveToSpinaShopProductBundles < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_product_bundles, :active, :boolean, default: false, null: false
  end
end
