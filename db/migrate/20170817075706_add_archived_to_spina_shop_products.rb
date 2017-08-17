class AddArchivedToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :archived, :boolean, default: false, null: false
  end
end
