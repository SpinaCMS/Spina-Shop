class AddChildrenCountToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :children_count, :integer, default: 0, null: false
  end
end
