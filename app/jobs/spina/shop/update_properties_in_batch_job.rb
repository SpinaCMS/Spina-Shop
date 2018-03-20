module Spina::Shop
  class UpdatePropertiesInBatchJob < ApplicationJob

    def perform(product_ids, property_params)
      Product.where(id: product_ids).each do |product|
        properties = product.properties || {}
        product.update(properties: properties.merge(property_params))
      end
    end

  end
end