class AddVolumeDiscountsToSpinaShopProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :spina_shop_products, :volume_discounts, :jsonb, default: [], null: false
  end
end
