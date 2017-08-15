class AddBusinessToSpinaShopTaxRates < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_tax_rates, :business, :boolean, default: false, null: false
  end
end
