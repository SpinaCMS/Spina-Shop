module Spina::Shop
  class UpdateProductsInBatchJob < ApplicationJob

    def perform(product_ids, product_params)
      # Order by children count desc so root products are handled first
      Product.where(id: product_ids).order(children_count: :desc).each do |product|
        product.update(product_params)
      end
    end

  end
end