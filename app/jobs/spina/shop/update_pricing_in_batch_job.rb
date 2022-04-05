module Spina::Shop
  class UpdatePricingInBatchJob < Spina::ApplicationJob

    def perform(product_ids, pricing_params)
      if pricing_params["price_for"].present?
        Product.where(id: product_ids).each do |product|
          price_exceptions = product.price_exceptions || {}
          price_for = pricing_params["price_for"].match(/\A(.*)\[(\d+)\]\z/)

          # Build price exception
          price_exception = {
            "price" => pricing_params["price"],
            "price_includes_tax" => pricing_params["price_includes_tax"],
            "#{price_for[1]}_id" => price_for[2]
          }

          # Find existing price exception
          index = price_exceptions.try(:[], price_for[1].pluralize)&.find_index do |h|
            h["#{price_for[1]}_id"].to_i == price_for[2].to_i
          end

          # Update existing or add new one
          if index.present?
            product.price_exceptions[price_for[1].pluralize][index] = price_exception
          else
            product.price_exceptions[price_for[1].pluralize] ||= []
            product.price_exceptions[price_for[1].pluralize] << price_exception
          end

          # Save product!
          product.save
        end
      else
        # Update base price
        Product.where(id: product_ids).each do |product|
          product.update({
            base_price: pricing_params["price"],
            price_includes_tax: pricing_params["price_includes_tax"]
          })
        end
      end
    end

  end
end