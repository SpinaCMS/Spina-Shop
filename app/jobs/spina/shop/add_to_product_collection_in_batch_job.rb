module Spina::Shop
  class AddToProductCollectionInBatchJob < ApplicationJob

    def perform(product_ids, product_collection_id)
      collection = ProductCollection.find(product_collection_id)
      collection.products << Product.where(id: product_ids)
    end

  end
end