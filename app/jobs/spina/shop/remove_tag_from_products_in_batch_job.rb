module Spina::Shop
  class RemoveTagFromProductsInBatchJob < ApplicationJob

    def perform(product_ids, tag_id)
      tag = Tag.find(tag_id)

      products = Product.where(id: product_ids)
      products.each do |product|
        product.tags.delete tag
      end
    end

  end
end