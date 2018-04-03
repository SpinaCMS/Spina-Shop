class AddParentIdToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :parent_id, :integer
    add_index :spina_shop_products, :parent_id
  end
end
