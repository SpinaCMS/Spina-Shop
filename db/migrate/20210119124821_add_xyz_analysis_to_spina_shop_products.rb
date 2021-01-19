class AddXyzAnalysisToSpinaShopProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_products, :xyz_analysis, :integer
  end
end
