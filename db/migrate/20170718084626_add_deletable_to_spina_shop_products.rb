class AddDeletableToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :deletable, :boolean, default: true, null: false
  end
end
