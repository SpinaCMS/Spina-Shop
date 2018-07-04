module Spina::Shop
  module Admin
    class CustomersController < AdminController
      before_action :set_breadcrumbs

      def index
        @q = Customer.ransack(params[:q])
        @customers = @q.result.sorted.page(params[:page]).per(25)
        @customer_groups = CustomerGroup.all
      end

      def new
        @customer = Customer.new
        add_breadcrumb t('spina.shop.customers.new')
        render layout: 'spina/admin/admin'
      end

      def create
        @customer = Customer.new(customer_params)
        if @customer.save
          redirect_to spina.shop_admin_customer_path(@customer)
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
        add_breadcrumb @customer.name, spina.shop_admin_customer_path(@customer)
        add_breadcrumb t('spina.edit')
        render layout: 'spina/admin/admin'
      end

      def update
        @customer = Customer.find(params[:id])
        if @customer.update_attributes(customer_params)
          redirect_to spina.shop_admin_customer_path(@customer)
        else
          add_breadcrumb t('spina.edit')
          render :edit
        end
      end

      def validate_vat_id
        @customer = Customer.find(params[:id])
        if vat_details = Valvat.new(@customer.vat_id).exists?(detail: true)
          render json: {valid: true, details: vat_details}
        else
          render json: {valid: false}
        end
      end

      private

        def customer_params
          params.require(:customer).permit(:first_name, :last_name, :email, :phone, :customer_group_id, :country_id, :company, :vat_id, addresses_attributes: [:id, :_destroy, :name, :street1, :street2, :postal_code, :city, :country_id, :house_number, :house_number_addition, :address_type])
        end

        def set_breadcrumbs
          add_breadcrumb Customer.model_name.human(count: 2), spina.shop_admin_customers_path
        end
    end
  end
end
