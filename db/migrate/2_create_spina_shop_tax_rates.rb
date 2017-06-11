class CreateSpinaShopTaxRates < ActiveRecord::Migration[5.0]
  def change
    create_table :spina_shop_tax_rates do |t|
      t.integer :tax_group_id
      t.decimal :rate, precision: 8, scale: 2, default: "0.0", null: false
      t.string :code
      t.integer :country_id
      t.boolean :business, default: false, null: false
      t.timestamps
    end

    add_index :spina_shop_tax_rates, :tax_group_id
    add_index :spina_shop_tax_rates, :country_id
  end
end
