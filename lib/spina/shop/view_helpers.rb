module Spina
  module Shop
    module ViewHelpers

      def products_for_select
        @products ||= Spina::Product.all.pluck(:name, :id)          
      end

    end
  end
end