module Spina::Shop
  module StockManagement
    module LocationsHelper

      def stock_locations
        unique_locations
      end

      def primary_stock_locations
        unique_locations.map do |location|
          location.match(/(\A\D*)/).try(:[], 0)
        end.uniq.compact.sort_by do |location|
          location.length > 2 ? '1' : '0' + location
        end
      end

      private

        def unique_locations
          @unique_locations ||= Spina::Shop::Product.active.where.not(location: "").pluck('location').uniq.compact.sort
        end

    end
  end
end