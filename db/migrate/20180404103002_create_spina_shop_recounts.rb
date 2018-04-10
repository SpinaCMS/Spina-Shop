class CreateSpinaShopRecounts < ActiveRecord::Migration[5.1]
  def change
    create_table :spina_shop_recounts do |t|
      t.integer :product_id
      t.integer :difference
      t.string :actor
      t.timestamps
    end

    add_index :spina_shop_recounts, :product_id
  end
end
