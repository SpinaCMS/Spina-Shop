module Spina::Shop
  class ReportJob < ApplicationJob
    include Rails.application.routes.url_helpers

    protected

      def default_url_options
        Rails.application.config.action_mailer.default_url_options
      end

  end
end