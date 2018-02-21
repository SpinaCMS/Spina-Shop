module Spina::Shop
  class UpdateProductsInBatchJob < ApplicationJob

    def perform(product_ids, product_params)
      Product.where(id: product_ids).update(product_params)
    end

  end
end