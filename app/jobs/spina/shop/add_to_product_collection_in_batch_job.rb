module Spina::Shop
  class AddToProductCollectionInBatchJob < Spina::ApplicationJob

    def perform(product_ids, product_collection_id)
      collection = ProductCollection.find(product_collection_id)
      collection.products << Product.where(id: product_ids)

      # Trigger save callback for parent products
      Product.where(id: product_ids).roots.where('children_count > 0').each(&:save)
    end

  end
end