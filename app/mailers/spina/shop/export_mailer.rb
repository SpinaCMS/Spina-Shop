module Spina::Shop
  class ExportMailer < ActionMailer::Base
    layout 'spina/shop/mail'

    def exported(url, email)
      @url = url

      mail(
        to: email, 
        from: current_account.email,
        subject: t('spina.shop.emails.exported_title')
      )
    end

    private

      def current_account
        Spina::Account.first # Replace with email setting Spina Shop
      end

  end
end