module Spina
  module Admin
    class CustomerAccountsController < ShopController
      load_and_authorize_resource :customer, class: "Spina::Customer"
      load_and_authorize_resource through: :customer, class: "Spina::CustomerAccount", singleton: true

      before_action :set_breadcrumbs

      def edit
        add_breadcrumb Spina::CustomerAccount.model_name.human
      end

      def update
        if @customer_account.update_attributes(customer_account_params)
          redirect_to [:admin, @customer]
        else
          add_breadcrumb Spina::CustomerAccount.model_name.human
          render :edit
        end
      end

      private

        def customer_account_params
          params.require(:customer_account).permit(:username, :password, :password_confirmation)
        end

        def set_breadcrumbs
          add_breadcrumb Spina::Customer.model_name.human(count: 2), admin_orders_path
          add_breadcrumb @customer.name, admin_customer_path(@customer)
        end
    end
  end
end