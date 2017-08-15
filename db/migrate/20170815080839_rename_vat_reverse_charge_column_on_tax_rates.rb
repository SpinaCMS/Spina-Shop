class RenameVatReverseChargeColumnOnTaxRates < ActiveRecord::Migration[5.1]
  def change
    rename_column :spina_shop_tax_rates, :reverse_charge_vat, :vat_reverse_charge
  end
end
