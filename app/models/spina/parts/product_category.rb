module Spina
  module Parts
    class ProductCategory < Base
      attr_json :product_category_id, :integer

      def content
        Spina::Shop::ProductCategory.find_by(id: product_category_id)
      end
      
    end
  end
end