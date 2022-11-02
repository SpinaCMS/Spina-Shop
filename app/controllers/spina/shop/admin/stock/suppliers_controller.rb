module Spina::Shop
  module Admin
    module Stock
      class SuppliersController < AdminController
        layout 'spina/shop/admin/stock'

        before_action :set_breadcrumbs

        def new
          @supplier = Supplier.new
          add_breadcrumb t('spina.shop.suppliers.new')
          render layout: 'spina/shop/admin/admin'
        end

        def create
          @supplier = Supplier.new(supplier_params)
          if @supplier.save
            redirect_to spina.edit_shop_admin_supplier_path(@supplier)
          else
            render :new
          end
        end

        def show
          @supplier = Supplier.find(params[:id])
          add_breadcrumb @supplier.name
          render layout: 'spina/shop/admin/admin'
        end

        def edit
          @supplier = Supplier.find(params[:id])
          add_breadcrumb @supplier.name
          render layout: 'spina/shop/admin/admin'
        end

        def index
          @suppliers = Supplier.order(:name)
        end

        def update
          @supplier = Supplier.find(params[:id])
          if @supplier.update(supplier_params)
            redirect_to spina.shop_admin_supplier_path(@supplier)
          else
            render :edit
          end
        end

        def destroy
          @supplier = Supplier.find(params[:id])
          @supplier.destroy
          redirect_to spina.shop_admin_suppliers_path
        rescue ActiveRecord::DeleteRestrictionError
          flash[:alert] = t('spina.shop.delete_restriction_error')
          flash[:alert_small] = t('spina.shop.delete_restriction_error_explanation')
          redirect_to spina.edit_shop_admin_supplier_path(@supplier)
        end

        private

          def set_breadcrumbs
            add_breadcrumb "Voorraad", spina.shop_admin_stock_forecast_path
            add_breadcrumb Supplier.model_name.human(count: 2), spina.shop_admin_suppliers_path
          end

          def supplier_params
            params.require(:supplier).permit(:name, :lead_time, :lead_time_standard_deviation, :contact_name, :email, :phone, :note, :average_stock_order_cost).delocalize({average_stock_order_cost: :number})
          end

      end
    end
  end
end
