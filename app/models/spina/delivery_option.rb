module Spina
  class DeliveryOption < ApplicationRecord
    belongs_to :tax_group
    belongs_to :sales_category

    has_many :orders, dependent: :restrict_with_exception

    def price_for_order(order)
      order.sub_total_including_tax >= BigDecimal(50) ? BigDecimal(0) : price
    end

    # Set this yourself
    def soonest_delivery_date
      today = Date.today
    end
  end
end