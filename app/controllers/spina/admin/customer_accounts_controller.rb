module Spina
  module Admin
    class CustomerAccountsController < AdminController
      before_action :set_customer
      before_action :set_breadcrumbs

      def edit
        @customer_account = @customer.customer_account
        add_breadcrumb Spina::CustomerAccount.model_name.human
      end

      def update
        @customer_account = @customer.customer_account
        if @customer_account.update_attributes(customer_account_params)
          redirect_to [:admin, @customer]
        else
          add_breadcrumb Spina::CustomerAccount.model_name.human
          render :edit
        end
      end

      private

        def set_customer
          @customer = Spina::Customer.find(params[:customer_id])
        end

        def customer_account_params
          params.require(:customer_account).permit(:email, :password, :password_confirmation)
        end

        def set_breadcrumbs
          add_breadcrumb Spina::Customer.model_name.human(count: 2), admin_orders_path
          add_breadcrumb @customer.name, admin_customer_path(@customer)
        end
    end
  end
end