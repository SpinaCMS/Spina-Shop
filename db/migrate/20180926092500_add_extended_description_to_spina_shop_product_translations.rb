class AddExtendedDescriptionToSpinaShopProductTranslations < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_product_translations, :extended_description, :text
  end
end
