module Spina
  class ProductRelation < ApplicationRecord
    belongs_to :product
    belongs_to :related_product, foreign_key: 'related_product_id', class_name: 'Product'
  end
end