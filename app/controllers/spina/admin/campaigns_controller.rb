module Spina
  module Admin
    class CampaignsController < AdminController
      # layout 'spina/admin/shop'

      def index
        add_breadcrumb "Campaigns", admin_campaigns_path
      end
    end
  end
end
