module Spina::Shop
  module StockManagement
    class StockManagementController < ActionController::Base
      protect_from_forgery with: :exception

      # before_action :authorize

      private

        def current_spina_user
          @current_spina_user ||= User.where(id: cookies.signed[:stock_management_spina_user_id]).first if cookies.signed[:stock_management_spina_user_id]
        end
        helper_method :current_user

        def authorize
          head 401 unless current_spina_user
        end
    end
  end
end