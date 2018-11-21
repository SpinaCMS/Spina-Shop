class CreateSpinaShopPropertyParts < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_property_parts do |t|
      t.string :content
      t.timestamps
    end
  end
end
