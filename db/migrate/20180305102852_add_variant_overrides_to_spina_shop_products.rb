class AddVariantOverridesToSpinaShopProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_products, :variant_overrides, :jsonb
  end
end
