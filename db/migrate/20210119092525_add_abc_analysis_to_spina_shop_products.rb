class AddAbcAnalysisToSpinaShopProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_products, :abc_analysis, :integer
  end
end
