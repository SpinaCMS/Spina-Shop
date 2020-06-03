class AddCategoryToSpinaShopStockLevelAdjustments < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_stock_level_adjustments, :category, :string
  end
end
