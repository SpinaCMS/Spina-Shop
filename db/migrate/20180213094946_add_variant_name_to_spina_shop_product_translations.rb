class AddVariantNameToSpinaShopProductTranslations < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_product_translations, :variant_name, :string
  end
end
