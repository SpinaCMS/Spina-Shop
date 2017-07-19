class CreateSpinaShopOrderAttachments < ActiveRecord::Migration[5.1]
  def change
    create_table :spina_shop_order_attachments do |t|
      t.string :name
      t.integer :order_id
      t.string :attachment_id
      t.string :attachment_filename
      t.string :attachment_size
      t.string :attachment_content_type
      t.timestamps
    end

    add_index :spina_shop_order_attachments, :order_id
  end
end
