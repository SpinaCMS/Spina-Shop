module Spina
  module Parts
    class ProductBundle < Base
      attr_json :product_bundle_id, :integer

      def content
        Spina::Shop::ProductBundle.find_by(id: product_bundle_id)
      end
      
    end
  end
end