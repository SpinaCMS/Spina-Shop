class AddUniqueIndexToOrderItems < ActiveRecord::Migration[5.2]
  def change
    add_index :spina_shop_order_items, [:order_id, :orderable_id, :orderable_type], unique: true, name: "spina_shop_unique_order_items_orderable"
  end
end
