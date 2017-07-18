class AddEditableSkuToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :editable_sku, :boolean, default: true, null: false
  end
end
