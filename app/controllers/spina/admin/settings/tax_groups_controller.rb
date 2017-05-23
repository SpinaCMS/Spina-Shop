module Spina
  module Admin
    module Settings
      class TaxGroupsController < ShopController
        before_action :set_breadcrumbs

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
            redirect_to spina.admin_settings_tax_groups_path
          else
            render :edit
          end
        end

        private

          def tax_group_params
            params.require(:tax_group).permit!
          end

          def set_breadcrumbs
            add_breadcrumb Spina::TaxGroup.model_name.human(count: 2), spina.admin_settings_tax_groups_path
          end
      end
    end
  end
end