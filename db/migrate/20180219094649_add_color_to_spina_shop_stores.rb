class AddColorToSpinaShopStores < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_stores, :color, :string
  end
end
