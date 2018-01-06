class AddLimitPerOrderToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :limit_per_order, :integer
    add_column :spina_shop_product_bundles, :limit_per_order, :integer
  end
end
