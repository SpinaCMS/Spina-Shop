module Spina::Shop
  module Admin
    module ProductsHelper

      def stores
        @stores ||= Spina::Shop::Store.all
      end

    end
  end
end