module Spina
  module Admin
    class CampaignsController < ShopController
      def index
        add_breadcrumb "Campaigns", admin_campaigns_path
      end
    end
  end
end
