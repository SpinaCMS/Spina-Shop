module Spina
  module Parts
    class Product < Base
      attr_json :product_id, :integer

      def content
        Spina::Shop::Product.find_by(id: product_id)
      end
      
    end
  end
end