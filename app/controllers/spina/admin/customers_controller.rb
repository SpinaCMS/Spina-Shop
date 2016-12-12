module Spina
  module Admin
    class CustomersController < ShopController
      before_action :set_breadcrumbs

      load_and_authorize_resource class: "Spina::Customer"

      def index
        @q = Customer.ransack(params[:q])
        @customers = @q.result.sorted.page(params[:page]).per(25)
      end

      def new
        add_breadcrumb t('spina.shop.customers.new')
      end

      def create
        if @customer.save
          redirect_to [:admin, @customer]
        else
          render :new
        end
      end

      def show
        add_breadcrumb @customer.name
      end

      def edit
        add_breadcrumb @customer.name, admin_customer_path(@customer)
        add_breadcrumb t('spina.edit')
      end

      def update
        if @customer.update_attributes(customer_params)
          redirect_to [:admin, @customer]
        else
          add_breadcrumb t('spina.edit')
          render :edit
        end
      end

      private

        def customer_params
          params.require(:customer).permit(:first_name, :last_name, :email, :phone, addresses_attributes: [:id, :_destroy, :street1, :street2, :postal_code, :city])
        end

        def set_breadcrumbs
          add_breadcrumb Spina::Customer.model_name.human(count: 2), admin_customers_path
        end
    end
  end
end
