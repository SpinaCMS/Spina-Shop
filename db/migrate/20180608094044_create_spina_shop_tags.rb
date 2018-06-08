class CreateSpinaShopTags < ActiveRecord::Migration[5.2]
  def change
    create_table :spina_shop_tags do |t|
      t.jsonb :name, default: {}
      t.timestamps
    end

    create_table :spina_shop_taggable_tags do |t|
      t.references :tag
      t.references :taggable, polymorphic: true
      t.timestamps
    end
  end
end
