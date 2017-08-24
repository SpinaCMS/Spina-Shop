class AddMetadataToPhotos < ActiveRecord::Migration[5.1]
  def change
    add_column :spina_shop_product_images, :file_filename, :string
    add_column :spina_shop_product_images, :file_size, :integer
    add_column :spina_shop_product_images, :file_content_type, :string
  end
end
