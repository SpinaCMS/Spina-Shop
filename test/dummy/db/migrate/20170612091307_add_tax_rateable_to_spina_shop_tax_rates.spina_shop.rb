# This migration comes from spina_shop (originally 4)
class AddTaxRateableToSpinaShopTaxRates < ActiveRecord::Migration[5.0]
  def change
    add_column :spina_shop_tax_rates, :tax_rateable_type, :string
    add_column :spina_shop_tax_rates, :tax_rateable_id, :integer
    remove_column :spina_shop_tax_rates, :country_id
    remove_column :spina_shop_tax_rates, :business
    add_index :spina_shop_tax_rates, [:tax_rateable_type, :tax_rateable_id], name: 'spina_tax_rates_tax_rateable_index'
  end
end
