module Spina::Shop
  module Admin
    module Analytics
      class CustomersController < AdminController
        layout "spina/shop/admin/analytics"

        before_action :set_view, if: -> { request.format.js? }
        before_action :set_period, if: -> { request.format.js? }
        before_action :set_breadcrumbs
        before_action -> { send(@view) if @view.present? && respond_to?(@view) }

        def customers_over_time
          @total_customers = Spina::Shop::Order.where.not(received_at: nil)
            .where(pos: false)
            .where("date_trunc('day', received_at) >= ? AND date_trunc('day', received_at) <= ?", @start_date, @end_date)
            .order("month")
            .group("month")
            .select("COUNT(DISTINCT email) as count, date_trunc('month', received_at) as month")

          @first_orders = Spina::Shop::Order.select("COUNT(*) as count, month")
            .where("month >= ? AND month <= ?", @start_date, @end_date)
            .from(
                Spina::Shop::Order.select("email, MIN(date_trunc('month', received_at)) as month")
                  .where(pos: false)
                  .where.not(received_at: nil)
                  .group("email")
            ).group("month")
          render :customers_over_time
        end

        def first_time_vs_returning
          @total_orders = Spina::Shop::Order.where.not(received_at: nil)
                      .where(pos: false)
                      .where("date_trunc('day', received_at) >= ? AND date_trunc('day', received_at) <= ?", @start_date, @end_date)
                      .order("date_trunc('month', received_at)")
                      .group("date_trunc('month', received_at)")
                      .joins(:order_items)
                      .select("SUM(unit_price * quantity - discount_amount) as total_orders, date_trunc('month', received_at) as month")

          @first_orders = Spina::Shop::Order.where(id: Spina::Shop::Order.select("(array_agg(id ORDER BY received_at))[1] as id").where(pos: false).where.not(received_at: nil).group("email"))
            .group("month")
            .joins(:order_items)
            .where("date_trunc('month', received_at) >= ? AND date_trunc('month', received_at) <= ?", @start_date, @end_date)
            .select("SUM(unit_price * quantity - discount_amount) as total_orders, date_trunc('month', received_at) as month")
            
          render :first_time_vs_returning
        end

        private

          def views
            [['Unieke klanten', 'customers_over_time'], ['Eerste bestelling vs terugkerende bestellingen', 'first_time_vs_returning'], ['Eenmalige klanten', 'one_time'], ['Terugkerende klanten', 'recurring']]
          end
          helper_method :views

          def set_period
            @start_date = Date.parse(params[:start_date])
            @end_date = Date.parse(params[:end_date])
            @group = params[:group]
          end

          def set_view
            @view = params[:view]
          end

          def set_breadcrumbs
            add_breadcrumb t('spina.shop.analytics.customers')
          end

      end
    end
  end
end