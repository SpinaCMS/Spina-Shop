class ChangeCodesToCaseInsensitiveFields < ActiveRecord::Migration[5.2]
  def down
    change_column :spina_shop_discounts, :code, :string
    change_column :spina_shop_gift_cards, :code, :string
  end

  def up
    change_column :spina_shop_discounts, :code, :citext
    change_column :spina_shop_gift_cards, :code, :citext
  end
end
