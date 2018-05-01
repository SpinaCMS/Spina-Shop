module Spina::Shop
  class AddToStoreInBatchJob < ApplicationJob

    def perform(product_ids, store_id)
      store = Store.find(store_id)
      store.products << Product.where(id: product_ids)
    end

  end
end