module Spina::Shop
  class UpdateProductsInBatchJob < ApplicationJob

    def perform(product_ids, product_params)
      Product.where(id: product_ids).each do |product|
        product.update_attributes(product_params)
      end
    end

  end
end