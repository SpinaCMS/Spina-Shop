module Spina
  class OrderMailer < ActionMailer::Base

    def confirmation(order)
      @order = order

      mail(
        to: order.email, 
        from: current_account.email, 
        subject: t('spina.shop.orders.confirmation.title')
      )
    end

    def shipped(order)
      @order = order

      mail(
        to: order.email,
        from: current_account.email,
        subject: t('spina.shop.orders.shipped.title')
      )
    end

    private

      def current_account
        Spina::Account.first # Replace with email setting Spina Shop
      end

  end
end