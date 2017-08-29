class AddBusinessToSpinaShopSalesCategoryCodes < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_sales_category_codes, :business, :boolean, default: false, null: false
  end
end
