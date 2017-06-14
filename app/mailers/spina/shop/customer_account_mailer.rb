module Spina::Shop
  class CustomerAccountMailer < ActionMailer::Base
    layout 'spina/shop/mail'

    def forgot_password(customer_account)
      @customer_account = customer_account

      mail(
        to: @customer_account.email, 
        from: current_account.email, 
        subject: t('spina.shop.emails.forgot_password_title')
      )
    end

    def welcome_email(customer_account)
      @customer_account = customer_account

      mail(
        to: customer_account.email, 
        from: current_account.email,
        subject: t('spina.shop.emails.welcome_email_title')
      )
    end

    private

      def current_account
        Spina::Account.first # Replace with email setting Spina Shop
      end

  end
end