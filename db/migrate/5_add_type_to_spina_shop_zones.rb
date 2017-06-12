class AddTypeToSpinaShopZones < ActiveRecord::Migration[5.0]
  def change
    add_column :spina_shop_zones, :type, :string
  end
end
