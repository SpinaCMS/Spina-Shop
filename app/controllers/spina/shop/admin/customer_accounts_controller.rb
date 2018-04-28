module Spina::Shop
  module Admin
    class CustomerAccountsController < AdminController
      before_action :set_customer
      before_action :set_breadcrumbs

      def new
        @customer_account = @customer.build_customer_account
        add_breadcrumb CustomerAccount.model_name.human
      end

      def create
        @customer_account = @customer.build_customer_account(customer_account_params)
        if @customer_account.save
          redirect_to spina.shop_admin_customer_path(@customer)
        else
          add_breadcrumb CustomerAccount.model_name.human
          render :new
        end
      end

      def edit
        @customer_account = @customer.customer_account
        add_breadcrumb CustomerAccount.model_name.human
      end

      def update
        @customer_account = @customer.customer_account
        if @customer_account.update_attributes(customer_account_params)
          redirect_to spina.shop_admin_customer_path(@customer)
        else
          add_breadcrumb CustomerAccount.model_name.human
          render :edit
        end
      end

      private

        def set_customer
          @customer = Customer.find(params[:customer_id])
        end

        def customer_account_params
          params.require(:customer_account).permit(:email, :password, :password_confirmation)
        end

        def set_breadcrumbs
          add_breadcrumb Customer.model_name.human(count: 2), spina.shop_admin_orders_path
          add_breadcrumb @customer.name, spina.shop_admin_customer_path(@customer)
        end
    end
  end
end