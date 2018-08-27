class ChangeColumnEmailToCitext < ActiveRecord::Migration[5.2]
  def up
    enable_extension("citext")
    change_column :spina_shop_customer_accounts, :email, :citext
  end

  def down
    disable_extension("citext")
    change_column :spina_shop_customer_accounts, :email, :string
  end
end
