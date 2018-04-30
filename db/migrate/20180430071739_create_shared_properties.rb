class CreateSharedProperties < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_shared_properties do |t|
      t.string :name
      t.timestamps
    end

    add_column :spina_shop_product_category_properties, :shared_property_id, :integer
    add_index :spina_shop_product_category_properties, :shared_property_id, name: "sp_pro_cat_pr_index_shared_pr"

    add_column :spina_shop_property_options, :property_id, :integer
    add_column :spina_shop_property_options, :property_type, :string
    add_index :spina_shop_property_options, [:property_id, :property_type], name: "sp_sh_pr_op_pr_id_pr_type_index"
  end
end
