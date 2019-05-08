class AddApprovedToSpinaShopShopReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :spina_shop_shop_reviews, :approved, :boolean, default: true, null: false
  end
end
