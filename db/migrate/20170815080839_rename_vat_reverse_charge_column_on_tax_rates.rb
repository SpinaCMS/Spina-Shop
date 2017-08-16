class RenameVatReverseChargeColumnOnTaxRates < ActiveRecord::Migration[5.1]
  def change
    remove_column :spina_shop_tax_rates, :reverse_charge_vat
  end
end
