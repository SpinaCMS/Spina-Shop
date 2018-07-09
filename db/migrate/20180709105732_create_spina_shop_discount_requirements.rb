class CreateSpinaShopDiscountRequirements < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_discount_requirements do |t|
      t.integer :discount_id
      t.string :type
      t.text :preferences
      t.timestamps
    end

    add_index :spina_shop_discount_requirements, :discount_id
  end
end
