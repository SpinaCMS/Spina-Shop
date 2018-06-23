class AddArchivedToSpinaShopProductBundles < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_product_bundles, :archived, :boolean, default: false, null: false
  end
end
