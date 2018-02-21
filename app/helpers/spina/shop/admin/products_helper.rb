module Spina::Shop
  module Admin
    module ProductsHelper

      def stores
        @stores ||= Spina::Shop::Store.all
      end

      def product_collections
        @product_collections ||= Spina::Shop::ProductCollection.all
      end

    end
  end
end