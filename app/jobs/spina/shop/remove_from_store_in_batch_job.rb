module Spina::Shop
  class RemoveFromStoreInBatchJob < ApplicationJob

    def perform(product_ids, store_id)
      store = Store.find(store_id)
      store.products.delete Product.where(id: product_ids)

      # Trigger save callback for parent products
      Product.where(id: product_ids).roots.where('children_count > 0').each(&:save)
    end

  end
end