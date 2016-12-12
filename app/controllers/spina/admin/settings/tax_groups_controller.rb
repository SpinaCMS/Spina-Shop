module Spina
  module Admin
    module Settings
      class TaxGroupsController < ShopController
        before_action :set_breadcrumbs

        load_and_authorize_resource class: "Spina::TaxGroup"

        def index
          add_breadcrumb I18n.t('spina.preferences.tax_groups'), spina.admin_settings_tax_groups_path
        end

        def edit
          add_breadcrumb @tax_group.name
        end

        def update
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
            @navigation_preferences_active = true
            add_breadcrumb I18n.t('spina.preferences.commerce'), spina.admin_settings_tax_groups_path
          end
      end
    end
  end
end