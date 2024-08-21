module Spina::Shop
  module Admin
    module Stock
      module StockOrdersHelper
      
        def minimum_expiration_period_warning?(stock_order, date)
          return false if Spina::Shop.config.minimum_expiration_period.blank?
          return false if stock_order.ordered_at.blank?
          (stock_order.ordered_at + Spina::Shop.config.minimum_expiration_period) > date
        end
      
      end
    end
  end
end