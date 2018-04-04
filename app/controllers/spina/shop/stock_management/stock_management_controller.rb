module Spina::Shop
  module StockManagement
    class StockManagementController < ActionController::Base
      protect_from_forgery with: :exception

      before_action :authorize

      private

        def current_spina_user
          @current_spina_user ||= Spina::User.where(id: cookies.signed[:stock_management_spina_user_id]).first if cookies.signed[:stock_management_spina_user_id]
        end
        helper_method :current_spina_user

        def authorize
          redirect_to spina.shop_stock_management_login_path unless current_spina_user
        end
    end
  end
end