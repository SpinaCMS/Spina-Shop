class AddParentIdToSpinaShopOrderItems < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_order_items, :parent_id, :integer
    add_index :spina_shop_order_items, :parent_id
  end
end
