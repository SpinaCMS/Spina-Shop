module Spina
  module Admin
    class CampaignsController < ShopController
      def index
        add_breadcrumb Spina::Campaign.model_name.human(count: 2), admin_campaigns_path
      end
    end
  end
end
