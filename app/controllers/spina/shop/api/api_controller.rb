module Spina::Shop
  module Api
    class ApiController < ActionController::Base      
      protect_from_forgery with: :exception
      
      before_action :authenticate
      
      private
      
        def authenticate
          authenticate_or_request_with_http_token do |token, options|
            Spina::Shop.config.api_key.present? && ActiveSupport::SecurityUtils.secure_compare(token, Spina::Shop.config.api_key)
          end
        end
    end
  end
end