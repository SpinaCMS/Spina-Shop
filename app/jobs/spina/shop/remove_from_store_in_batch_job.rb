module Spina::Shop
  class RemoveFromStoreInBatchJob < ApplicationJob

    def perform(product_ids, store_id)
      store = Store.find(store_id)

      Product.where(id: product_ids).order('children_count DESC').each do |product|
        product.stores = (product.stores - [store]).uniq
        product.variant_overrides ||= {}
        product.variant_overrides["stores"] ||= []
        product.variant_overrides["stores"] = product.store_ids.sort != product.parent&.store_ids&.sort
        product.save
      end

      # Trigger save callback for parent products
      Product.where(id: product_ids).roots.where('children_count > 0').each(&:save)
    end

  end
end