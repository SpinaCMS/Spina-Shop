class CreateSpinaShopProductReturns < ActiveRecord::Migration[6.1]
  def change
    create_table :spina_shop_product_returns do |t|
      t.integer :order_id, index: true, null: false
      t.text :note
      t.string :reason
      t.datetime :closed_at

      t.timestamps
    end
  end
end
