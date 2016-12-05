module Spina
  module Admin
    class CustomerAccountsController < AdminController
      load_and_authorize_resource :customer, class: "Spina::Customer"
      load_and_authorize_resource through: :customer, class: "Spina::CustomerAccount", singleton: true

      before_action :set_breadcrumbs

      def edit
        add_breadcrumb "Account"
      end

      def update
        if @customer_account.update_attributes(customer_account_params)
          redirect_to [:admin, @customer]
        else
          add_breadcrumb "Account"
          render :edit
        end
      end

      private

        def customer_account_params
          params.require(:customer_account).permit(:username, :password, :password_confirmation)
        end

        def set_breadcrumbs
          add_breadcrumb "Klanten", admin_orders_path
          add_breadcrumb @customer.name, admin_customer_path(@customer)
        end
    end
  end
end