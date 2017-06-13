module Spina::Shop
  module Admin
    module Settings
      class TaxGroupsController < ShopController
        layout 'spina/admin/admin', except: [:index]
        
        before_action :set_breadcrumbs

        def new
          @tax_group = TaxGroup.new
          @tax_group.tax_rates.build
        end

        def create
          @tax_group = TaxGroup.new(tax_group_params)
          unless @tax_group.save
            flash[:alert] = "Failed to save"
          end
          redirect_to spina.shop_admin_settings_tax_groups_path
        end

        def index
          @tax_groups = TaxGroup.all
        end

        def edit
          @tax_group = TaxGroup.find(params[:id])
          add_breadcrumb @tax_group.name
        end

        def update
          @tax_group = TaxGroup.find(params[:id])
          if @tax_group.update_attributes(tax_group_params)
            redirect_to spina.shop_admin_settings_tax_groups_path
          else
            render :edit
          end
        end

        private

          def tax_group_params
            params.require(:tax_group).permit(:name, tax_rates_attributes: [:rate, :code])
          end

          def set_breadcrumbs
            add_breadcrumb TaxGroup.model_name.human(count: 2), spina.shop_admin_settings_tax_groups_path
          end
      end
    end
  end
end