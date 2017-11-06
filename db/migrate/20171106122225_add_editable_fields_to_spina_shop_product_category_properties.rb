class AddEditableFieldsToSpinaShopProductCategoryProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_product_category_properties, :editable, :boolean, default: false, null: false
    add_column :spina_shop_product_category_properties, :editable_options, :boolean, default: false, null: false
  end
end
