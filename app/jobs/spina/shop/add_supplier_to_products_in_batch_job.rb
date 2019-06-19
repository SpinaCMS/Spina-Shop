module Spina::Shop
  class AddSupplierToProductsInBatchJob < ApplicationJob

    def perform(product_ids, supplier_id, supplier_packing_unit)
      ids = Product.where(id: product_ids).joins(:children).pluck("children_spina_shop_products.id, spina_shop_products.id").flatten.uniq
      Product.where(id: ids).update_all(supplier_id: supplier_id, supplier_packing_unit: supplier_packing_unit)
    end

  end
end