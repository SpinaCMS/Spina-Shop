module Spina::Shop
  module Admin
    class CustomersController < AdminController
      before_action :set_breadcrumbs

      def index
        @q = Customer.ransack(params[:q])
        @customers = @q.result
        @customers = @customers.where(store_id: params[:store_id]) if params[:store_id].present?
        @customers = @customers.sorted.page(params[:page]).per(25)
        @customer_groups = CustomerGroup.all

        respond_to do |format|
          format.html
          format.js
          format.json do
            results = @customers.reorder(:company, :full_name).map do |customer|
              { id:           customer.id, 
                full_name:    customer.full_name,
                company:      customer.company,
                name:         customer.name
              }
            end
            render inline: {results: results, total_count: @q.result.count}.to_json
          end
        end
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

        respond_to do |format|
          format.html
          format.json do
            render inline: {
              id: @customer.id,
              first_name: @customer.first_name,
              last_name: @customer.last_name,
              email: @customer.email,
              phone: @customer.phone,
              company: @customer.company,
              billing_street_1: @customer.default_address&.street1,
              billing_street_2: @customer.default_address&.street2,
              billing_house_number: @customer.default_address&.house_number,
              billing_house_number_addition: @customer.default_address&.house_number_addition,
              billing_postal_code: @customer.default_address&.postal_code,
              billing_city: @customer.default_address&.city,
              billing_country: @customer.default_address&.country_id
            }.to_json
          end
        end
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

      def destroy
        @customer = Customer.find(params[:id])
        @customer.destroy
        redirect_to spina.shop_admin_customers_path
      rescue ActiveRecord::DeleteRestrictionError
        flash[:alert] = t('spina.shop.customers.delete_restriction_error', name: @customer.name)
        flash[:alert_small] = t('spina.shop.customers.delete_restriction_error_explanation')
        redirect_to spina.shop_admin_customer_path(@customer)
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
          params.require(:customer).permit(:first_name, :last_name, :email, :phone, :customer_group_id, :country_id, :company, :postpay_allowed, :vat_id, addresses_attributes: [:id, :_destroy, :first_name, :last_name, :company, :street1, :street2, :postal_code, :city, :country_id, :house_number, :house_number_addition, :address_type])
        end

        def set_breadcrumbs
          add_breadcrumb Customer.model_name.human(count: 2), spina.shop_admin_customers_path
        end
    end
  end
end
