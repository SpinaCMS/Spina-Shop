module Spina::Shop
  module Admin
    module Stock
      class StockOrdersController < AdminController
        layout 'spina/shop/admin/stock'

        before_action :set_breadcrumbs

        def index
          @stock_orders = StockOrder.where(closed_at: nil).order(ordered_at: :desc, created_at: :desc)
          @closed_stock_orders = StockOrder.closed.order(ordered_at: :desc, created_at: :desc)
        end

        def show
          @stock_order = StockOrder.find(params[:id])
          add_breadcrumb "##{@stock_order.id}"

          respond_to do |format|
            format.html { render layout: 'spina/admin/admin' }
            format.pdf do
              pdf = StockOrderPdf.new(@stock_order)
              send_data pdf.render, filename: "order-#{@stock_order.id}.pdf", type: "application/pdf"
            end
            format.xlsx do
              file = StockOrderToExcel.new(@stock_order).to_excel
              send_data file, filename: "order-#{@stock_order.id}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            end
          end
        end

        def new
          @stock_order = StockOrder.new
          @suppliers = Supplier.order(:name)
        end

        def create
          @stock_order = StockOrder.create(stock_order_params)
          redirect_to spina.shop_admin_stock_orders_path
        end

        def edit
          @stock_order = StockOrder.find(params[:id])
          @suppliers = Supplier.order(:name)
          add_breadcrumb "##{@stock_order.id}", spina.shop_admin_stock_order_path(@stock_order)
          add_breadcrumb t("spina.edit")
          render layout: 'spina/admin/admin'
        end

        def update
          @stock_order = StockOrder.find(params[:id])
          if @stock_order.update_attributes(stock_order_params)
            redirect_to spina.shop_admin_stock_order_path(@stock_order)
          else
            render :edit
          end
        end

        def destroy
          @stock_order = StockOrder.find(params[:id])
          @stock_order.destroy
          redirect_to spina.shop_admin_stock_orders_path
        rescue ActiveRecord::DeleteRestrictionError
          flash[:alert] = t('spina.shop.delete_restriction_error')
          flash[:alert_small] = t('spina.shop.delete_restriction_error_explanation')
          redirect_to spina.shop_admin_stock_order_path(@stock_order)
        end

        def place_order
          @stock_order = StockOrder.concept.find(params[:id])
          @stock_order.place_order!
          redirect_to spina.shop_admin_stock_order_path(@stock_order)
        end

        def close_order
          @stock_order = StockOrder.open.find(params[:id])
          @stock_order.update_attributes(closed_at: Time.zone.now)
          redirect_to spina.shop_admin_stock_order_path(@stock_order)
        end

        private

          def set_breadcrumbs
            add_breadcrumb "Voorraad", spina.shop_admin_stock_forecast_path
            add_breadcrumb StockOrder.model_name.human(count: 2), spina.shop_admin_stock_orders_path
          end

          def stock_order_params
            params.require(:stock_order).permit(:supplier_id, :delivery_tracking_url, :note, :expected_delivery)
          end

      end
    end
  end
end
