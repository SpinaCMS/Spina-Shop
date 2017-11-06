class CreatePropertyOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :spina_shop_property_options do |t|
      t.string :name
      t.integer :product_category_property_id
      t.timestamps
    end
    add_index :spina_shop_property_options, :product_category_property_id, name: 'index_spina_shop_pr_options_on_pr_cat_property_id'

    create_table :spina_shop_property_option_translations do |t|
      t.integer :spina_shop_property_option_id
      t.string :locale
      t.string :label
      t.timestamps
    end
    add_index :spina_shop_property_option_translations, :locale
    add_index :spina_shop_property_option_translations, :spina_shop_property_option_id, name: 'idx_sp_shp_pr_op_translations_123'
  end
end
