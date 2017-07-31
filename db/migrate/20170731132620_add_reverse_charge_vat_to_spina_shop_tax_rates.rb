class AddReverseChargeVatToSpinaShopTaxRates < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_tax_rates, :reverse_charge_vat, :boolean, default: false, null: false
  end
end
