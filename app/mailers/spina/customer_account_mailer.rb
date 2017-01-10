module Spina
  class CustomerAccountMailer < ActionMailer::Base
    layout 'spina/mail'

    def forgot_password(customer_account)
      @customer_account = customer_account

      mail(
        to: @customer_account.email, 
        from: current_account.email, 
        subject: t('spina.shop.customer_accounts.forgot_password.title')
      )
    end

    private

      def current_account
        Spina::Account.first # Replace with email setting Spina Shop
      end

  end
end