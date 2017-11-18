class AddPromotionalPriceToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :promotional_price, :decimal, precision: 8, scale: 2
    rename_column :spina_shop_products, :price, :base_price
  end
end
