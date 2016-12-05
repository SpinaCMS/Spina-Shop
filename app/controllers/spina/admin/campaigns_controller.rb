module Spina
  module Admin
    class CampaignsController < AdminController
      # layout 'spina/admin/shop'

      def index
        add_breadcrumb "Acties", admin_campaigns_path
      end
    end
  end
end
