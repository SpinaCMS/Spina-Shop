module Spina::Shop
  class RemoveFromProductCollectionInBatchJob < ApplicationJob

    def perform(product_ids, product_collection_id)
      collection = ProductCollection.find(product_collection_id)
      collection.products.delete Product.where(id: product_ids)
    end

  end
end