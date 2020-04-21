module Spina::Shop
  module Admin
    module Analytics
      class CustomersController < AdminController
        layout "spina/shop/admin/analytics"

        before_action :set_breadcrumbs

        def index
          @total_orders = Spina::Shop::Order.where.not(received_at: nil)
                      .where(pos: false)
                      .order("date_trunc('month', received_at)")
                      .group("date_trunc('month', received_at)")
                      .select("COUNT(*) as count, date_trunc('month', received_at) as month")

          @first_orders = Spina::Shop::Order.select("COUNT(*) as count, month").from(Spina::Shop::Order.select("email, MIN(date_trunc('month', received_at)) as month").where(pos: false).where.not(received_at: nil).group("email")).group("month")
        end

        private

          def set_breadcrumbs
            add_breadcrumb t('spina.shop.analytics.customers')
          end

      end
    end
  end
end