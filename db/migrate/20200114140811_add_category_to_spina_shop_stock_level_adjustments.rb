class AddCategoryToSpinaShopStockLevelAdjustments < ActiveRecord::Migration[6.0]
  def change
    add_column :spina_shop_stock_level_adjustments, :category, :string
  end
end
