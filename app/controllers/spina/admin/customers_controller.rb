module Spina
  module Admin
    class CustomersController < AdminController
      before_action :set_breadcrumbs

      def index
        @q = Customer.ransack(params[:q])
        @customers = @q.result.sorted.page(params[:page]).per(25)
      end

      def new
        @customer = Customer.new
        add_breadcrumb t('spina.shop.customers.new')
      end

      def create
        @customer = Customer.find(params[:id])
        if @customer.save
          redirect_to [:admin, @customer]
        else
          render :new
        end
      end

      def show
        @customer = Customer.find(params[:id])
        add_breadcrumb @customer.name
      end

      def edit
        @customer = Customer.find(params[:id])
        add_breadcrumb @customer.name, admin_customer_path(@customer)
        add_breadcrumb t('spina.edit')
      end

      def update
        @customer = Customer.find(params[:id])
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
