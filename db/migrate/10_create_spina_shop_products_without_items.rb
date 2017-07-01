class CreateSpinaShopProductsWithoutItems < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :sku, :string
    add_column :spina_shop_products, :location, :string
    add_column :spina_shop_products, :tax_group_id, :integer
    add_column :spina_shop_products, :weight, :decimal, precision: 8, scale: 3
    add_column :spina_shop_products, :price, :decimal, precision: 8, scale: 2
    add_column :spina_shop_products, :cost_price, :decimal, precision: 8, scale: 2
    add_column :spina_shop_products, :ean, :string
    add_column :spina_shop_products, :sales_category_id, :integer
    add_column :spina_shop_products, :must_be_of_age_to_buy, :boolean, default: false
    add_column :spina_shop_products, :can_expire, :boolean, default: false
    add_column :spina_shop_products, :expiration_date, :date
    add_column :spina_shop_products, :stock_level, :integer, default: 0, null: false
    add_column :spina_shop_products, :supplier_reference, :string

    add_column :spina_shop_stock_level_adjustments, :product_id, :integer

    add_index :spina_shop_products, :tax_group_id
    add_index :spina_shop_products, :sales_category_id
    add_index :spina_shop_stock_level_adjustments, :product_id
  end
end
