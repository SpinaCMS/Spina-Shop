module Spina::Shop
  class OrderMailer < ActionMailer::Base
    layout 'spina/shop/mail'

    def confirmation(order)
      @order = order

      mail(
        to: order.email, 
        from: "#{current_account.name} <#{current_account.email}>",
        subject: t('spina.shop.emails.order_confirmation_title')
      )
    end

    def payment_reminder(order)
      @order = order

      mail(
        to: order.email,
        from: "#{current_account.name} <#{current_account.email}>",
        subject: t('spina.shop.emails.payment_reminder_title')
      )
    end

    def shipped(order)
      @order = order

      mail(
        to: order.email,
        from: "#{current_account.name} <#{current_account.email}>",
        subject: t('spina.shop.emails.order_shipped_title')
      )
    end

    private

      def current_account
        Spina::Account.first # Replace with email setting Spina Shop
      end

  end
end