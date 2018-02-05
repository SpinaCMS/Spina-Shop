class CreateProductBundleTranslations < ActiveRecord::Migration[5.1]
  def change
    create_table :spina_shop_product_bundle_translations do |t|
      t.integer :spina_shop_product_bundle_id, null: false
      t.string :locale, null: false
      t.string :name
      t.text :description
      t.string :seo_title
      t.string :seo_description
      t.string :materialized_path
      t.timestamps
    end

    add_index :spina_shop_product_bundle_translations, :locale
    add_index :spina_shop_product_bundle_translations, :spina_shop_product_bundle_id, name: "product_bundle_tranlations_index"
  end
end
