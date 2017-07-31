# This migration comes from spina_shop (originally 20170718084146)
class AddEditableSkuToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :editable_sku, :boolean, default: true, null: false
  end
end
