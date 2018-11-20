class CreateSpinaShopProductCategoryParts < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_product_category_parts do |t|
      t.integer :product_category_id
      t.timestamps
    end
  end
end
