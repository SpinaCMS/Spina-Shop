module Spina::Shop
  module StockManagement
    class SessionsController < StockManagementController
      skip_before_action :authorize

      def new
      end

      def create
        user = Spina::User.where(email: params[:email]).first
        if user && user.authenticate(params[:password])
          cookies.signed.permanent[:spina_user_id] = user.id
          user.update_last_logged_in!
          redirect_to spina.shop_stock_management_root_path
        else
          flash.now[:alert] = I18n.t('spina.notifications.wrong_username_or_password')
          render "new"
        end
      end

      def destroy
        cookies.delete(:spina_user_id)
        redirect_to spina.shop_stock_management_login_path
      end

    end
  end
end