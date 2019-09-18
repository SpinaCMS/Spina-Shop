class ChangeEmailColumnsToCitext < ActiveRecord::Migration[5.2]

  def down
    change_column :spina_shop_customers, :email, :string
    change_column :spina_shop_in_stock_reminders, :email, :string
    change_column :spina_shop_orders, :email, :string
    change_column :spina_shop_product_reviews, :email, :string
    change_column :spina_shop_shop_reviews, :email, :string
  end

  def up
    change_column :spina_shop_customers, :email, :citext
    change_column :spina_shop_in_stock_reminders, :email, :citext
    change_column :spina_shop_orders, :email, :citext
    change_column :spina_shop_product_reviews, :email, :citext
    change_column :spina_shop_shop_reviews, :email, :citext
  end
end
