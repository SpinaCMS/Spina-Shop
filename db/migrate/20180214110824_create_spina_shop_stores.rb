class CreateSpinaShopStores < ActiveRecord::Migration[5.1]
  def change
    create_table :spina_shop_stores do |t|
      t.string :name
      t.timestamps
    end
  end
end
