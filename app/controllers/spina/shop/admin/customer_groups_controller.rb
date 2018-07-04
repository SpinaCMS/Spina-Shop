module Spina::Shop
  module Admin
    class CustomerGroupsController < AdminController
      layout 'spina/shop/admin/customers', only: 'index'

      before_action :set_breadcrumbs

      def index
        @customer_groups = CustomerGroup.ordered
      end

      def new
        @customer_group = CustomerGroup.new
        add_breadcrumb t('spina.shop.customer_groups.new')
      end

      def create
        @customer_group = CustomerGroup.new(customer_group_params)

        if @customer_group.save
          redirect_to spina.shop_admin_customer_groups_path
        else
          render :new
        end
      end

      def edit
        @customer_group = CustomerGroup.find(params[:id])
        add_breadcrumb @customer_group.name
      end

      def update
        @customer_group = CustomerGroup.find(params[:id])

        if @customer_group.update_attributes(customer_group_params)
          redirect_to spina.shop_admin_customer_groups_path
        else
          render :edit
        end
      end

      def destroy
        @customer_group = CustomerGroup.find(params[:id])
        @customer_group.destroy
        redirect_to spina.shop_admin_customer_groups_path
      end

      private

        def customer_group_params
          params.require(:customer_group).permit(:name, :parent_id)
        end

        def set_breadcrumbs
          add_breadcrumb t('spina.shop.customer_groups.title'), spina.shop_admin_customer_groups_path
        end

    end
  end
end